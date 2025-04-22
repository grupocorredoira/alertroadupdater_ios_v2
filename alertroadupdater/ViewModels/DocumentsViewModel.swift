import Foundation
import Combine
import SwiftUI

/// `DocumentsViewModel` gestiona los documentos y su estado de descarga en iOS.
/// Se encarga de obtener documentos desde Firestore y sincronizarlos con almacenamiento local.

class DocumentsViewModel: ObservableObject {

    private let firestoreRepository: FirestoreRepository
    private let localRepository: LocalRepository

    @Published var documentDownloadStates: [String: DocumentDownloadStatus] = [:]
    @Published var downloadError: String? = nil // ✅ Se define explícitamente como opcional
    @Published var documents: [Document] = []

    private var cancellables = Set<AnyCancellable>()

    init(firestoreRepository: FirestoreRepository, localRepository: LocalRepository) {
        self.firestoreRepository = firestoreRepository
        self.localRepository = localRepository
        loadDocumentsFromExternalDatabase()
    }

    func refreshDocuments () {
        loadDocumentsFromExternalDatabase()
    }

    /// Carga documentos desde Firestore y sincroniza con almacenamiento local.
    private func loadDocumentsFromExternalDatabase() {
        firestoreRepository.loadDocumentsFromFirestore()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error cargando documentos: \(error.localizedDescription)")
                }
            } receiveValue: { fetchedDocuments in
                self.documents = fetchedDocuments
                self.initializeDocumentDownloadStates(fetchedDocuments)
            }
            .store(in: &cancellables)
    }

    /// Inicializa el estado de descarga de los documentos.
    private func initializeDocumentDownloadStates(_ documents: [Document]) {
        let updatedStates = documents.reduce(into: [String: DocumentDownloadStatus]()) { result, document in
            let isStored = localRepository.isDocumentStored(documentId: document.id) // ✅ Corrección de argumento
            result[document.id] = isStored ? .downloaded : .available
        }
        DispatchQueue.main.async {
            self.documentDownloadStates = updatedStates
        }
    }

    /// Obtiene una lista de SSIDs únicos, manteniendo el orden original.
    func getAllSSIDs() -> [String] {
        var seen = Set<String>()
        var uniqueSSIDs: [String] = []

        for document in documents {
            let ssid = document.ssid
            if !seen.contains(ssid) {
                seen.insert(ssid)
                uniqueSSIDs.append(ssid)
            }
        }

        return uniqueSSIDs
    }

    /// Busca la contraseña asociada a un SSID.
    func getPasswordForSSID(_ ssid: String) -> String? {
        return documents.first(where: { $0.ssid == ssid })?.password
    }

    /// Descarga un archivo desde Firestore y lo guarda localmente.
    func downloadFileAndWait(documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        updateDownloadState(documentId, newState: .downloading(progress: 0))

        FileDownloadManager.downloadFileFromFirebaseStorage(
            fileName: documentId,
            onSuccess: { fileURL in
                DispatchQueue.main.async { // ✅ Corrección del uso de DispatchQueue
                    FileDownloadManager.downloadFileWithURL(
                        fileName: documentId,
                        fileUrl: fileURL
                    ) { result in
                        switch result {
                        case .success:
                            self.updateDownloadState(documentId, newState: .downloaded)
                            print("Documento \(documentId) descargado exitosamente.")

                            // 📦 Ruta esperada de almacenamiento local
                            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let destinationURL = documentsDir.appendingPathComponent("Documents").appendingPathComponent(documentId)
                            //print("✅ [downloadFileAndWait] Documento '\(documentId)' guardado en: \(destinationURL.path)")

                            completion(.success(()))
                        case .failure(let error):
                            print("Error al descargar \(documentId): \(error.localizedDescription)")
                            self.updateDownloadState(documentId, newState: .available)
                            completion(.failure(error))
                        }
                    }
                }
            },
            onError: { error in
                DispatchQueue.main.async { // ✅ Corrección del uso de DispatchQueue
                    print("Error obteniendo URL de \(documentId): \(error.localizedDescription)")
                    self.updateDownloadState(documentId, newState: .available)
                    completion(.failure(error))
                }
            }
        )
    }

    /// Descarga todos los documentos asociados a un SSID.
    func downloadAllDocumentsBySSID(ssid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentsToDownload = documents.filter { $0.ssid == ssid }
        let dispatchGroup = DispatchGroup()
        var errors: [Error] = []

        for document in documentsToDownload {
            dispatchGroup.enter()
            downloadFileAndWait(documentId: document.id) { result in
                if case .failure(let error) = result {
                    errors.append(error)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if errors.isEmpty {
                self.downloadError = nil // ✅ Si todo salió bien, no hay error.
                completion(.success(()))
            } else {
                self.downloadError = "Error al descargar algunos archivos. Inténtalo de nuevo." // ✅ Mensaje de error
                completion(.failure(errors.first!))
            }
        }
    }

    /// Actualiza el estado de descarga de un documento.
    private func updateDownloadState(_ documentId: String, newState: DocumentDownloadStatus) {
        DispatchQueue.main.async { // ✅ Corrección del uso de DispatchQueue
            self.documentDownloadStates[documentId] = newState
        }
    }

    /// Obtiene el nombre del dispositivo asociado a un SSID.
    func getDeviceNameForSSID(_ ssid: String) -> String? {
        return documents.first(where: { $0.ssid == ssid })?.deviceName
    }

    /// Obtiene el SSID asociado a un nombre de dispositivo.
    func getSSIDForDeviceName(_ deviceName: String) -> String {
        let trimmedDevice = deviceName.trimmingCharacters(in: .whitespaces)
        guard let ssid = documents.first(where: { $0.deviceName.trimmingCharacters(in: .whitespaces) == trimmedDevice })?.ssid else {
            fatalError("❌ No se encontró SSID para el deviceName '\(deviceName)'")
        }
        return ssid
    }

    /// Elimina todos los archivos locales almacenados.
    func deleteAllLocalFiles() -> String {
        switch localRepository.deleteAllDocuments() {
        case .noFiles:
            return "No hay archivos para eliminar"
        case .success:
            return "Archivos eliminados con éxito"
        case .error(let failedFiles):
            return "Error eliminando archivos:\n" + failedFiles.joined(separator: "\n")
        }
    }
}

/// Representa los estados de descarga de un documento.
enum DocumentDownloadStatus {
    case available
    case downloaded
    case downloading(progress: Int)

    /// Convierte el estado en una cadena legible.
    func toReadableString() -> String {
        switch self {
        case .available:
            return "Disponible para descargar"
        case .downloaded:
            return "Descargado"
        case .downloading(let progress):
            return "Descargando... \(progress)%"
        }
    }
}

