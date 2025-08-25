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

    /// Obtiene una lista de SSIDs únicos sin barra baja, manteniendo el orden original.
    func getAllSSIDsWithoutUnderscore() -> [String] {
        var seen = Set<String>()
        var filteredSSIDs: [String] = []

        for document in documents {
            let ssid = document.ssid
            if !ssid.contains("_") && !seen.contains(ssid) {
                seen.insert(ssid)
                filteredSSIDs.append(ssid)
            }
        }

        return filteredSSIDs
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
                            // TODO - WARNING: solved, es por los prints
                            let destinationURL = documentsDir.appendingPathComponent(AppConstants.deviceStorageDocumentsFolder).appendingPathComponent(documentId)
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
                self.downloadError = nil
                completion(.success(()))
            } else {
                self.downloadError = "error_downloading_files".localized
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

    /// Obtiene la IP asociada a un nombre de dispositivo.
    func getIPForDeviceName(_ deviceName: String) -> String {
        let trimmedDevice = deviceName.trimmingCharacters(in: .whitespaces)
        guard let ip = documents.first(where: { $0.deviceName.trimmingCharacters(in: .whitespaces) == trimmedDevice })?.ip else {
            fatalError("❌ No se encontró IP para el deviceName '\(deviceName)'")
        }
        return ip
    }

    /// Obtiene el puerto asociado a un nombre de dispositivo.
    func getPortForDeviceName(_ deviceName: String) -> UInt16 {
        let trimmedDevice = deviceName.trimmingCharacters(in: .whitespaces)
        guard let port = documents.first(where: { $0.deviceName.trimmingCharacters(in: .whitespaces) == trimmedDevice })?.port else {
            fatalError("❌ No se encontró puerto para el deviceName '\(deviceName)'")
        }
        return UInt16(port)
    }


    /// Elimina todos los archivos locales almacenados.
    func deleteAllLocalFiles() -> String {
        switch localRepository.deleteAllDocuments() {
        case .noFiles:
            // 🔁 Localización del mensaje
            return "delete_no_files".localized
        case .success:
            return "delete_success".localized
        case .error(let failedFiles):
            return "delete_error_prefix".localized + failedFiles.joined(separator: "\n")
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
            return "download_status_available".localized
        case .downloaded:
            return "download_status_downloaded".localized
        case .downloading(let progress):
            return String(format: "download_status_downloading".localized, progress)
        }
    }
}

