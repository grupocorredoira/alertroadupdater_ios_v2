import Foundation
import Combine

class UploadDocumentsViewModel: ObservableObject {
    private let localRepository: LocalRepository

    @Published var uploadStates: [String: DocumentUploadStatus] = [:]

    private var cancellables = Set<AnyCancellable>()


    @Published private(set) var documents: [Document] = []

    init(localRepository: LocalRepository, documentsViewModel: DocumentsViewModel) {
        self.localRepository = localRepository

        documentsViewModel.$documents
            .receive(on: DispatchQueue.main)
            .assign(to: \.documents, on: self)
            .store(in: &cancellables)
    }

    func updateUploadStatus(documentId: String, newStatus: DocumentUploadStatus) {
        DispatchQueue.main.async {
            self.uploadStates[documentId] = newStatus
        }
    }
    
    func getDocumentsStoredLocallyForDevice(deviceName: String?) -> [Document] {
        //print("📥 Buscando documentos locales para deviceName: '\(deviceName ?? "nil")'")

        for doc in documents {
            let stored = localRepository.isDocumentStored(documentId: doc.id)
            // TODO - WARNING: solved, es por los prints
            //print("➡️ \(doc.deviceName) | ID: \(doc.id) | Guardado localmente: \(stored)")
        }

        let filtered = documents.filter {
            $0.deviceName == deviceName &&
            localRepository.isDocumentStored(documentId: $0.id)
        }

        //(print("✅ Documentos encontrados: \(filtered.count)")
        return filtered
    }

    func uploadDocument(_ document: Document, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🚀 Iniciando subida del documento: \(document.id)")
        updateUploadStatus(documentId: document.id, newStatus: .uploading(progress: 0))

        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            let message = "❌ No se pudo acceder al directorio de documentos"
            print(message)
            DispatchQueue.main.async {
                self.updateUploadStatus(documentId: document.id, newStatus: .error(message: message))
                completion(.failure(NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: message])))
            }
            return
        }

        let fileURL = documentsDirectory.appendingPathComponent(document.id)
        print("📄 Archivo localizado en: \(fileURL.path)")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            let message = "❌ Archivo no encontrado localmente: \(document.id)"
            print(message)
            DispatchQueue.main.async {
                self.updateUploadStatus(documentId: document.id, newStatus: .error(message: message))
                completion(.failure(NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: message])))
            }
            return
        }

        let uploader = TCPNetworkManager()

        uploader.onProgress = { percent in
            print("📊 Progreso \(document.id): \(percent)%")
            DispatchQueue.main.async {
                self.updateUploadStatus(documentId: document.id, newStatus: .uploading(progress: percent))
            }
        }

        uploader.onComplete = {
            print("✅ Subida completada: \(document.id)")
            DispatchQueue.main.async {
                self.updateUploadStatus(documentId: document.id, newStatus: .uploaded)
                completion(.success(()))
            }
        }

        uploader.onError = { errorMessage in
            print("❗️Error al subir \(document.id): \(errorMessage)")
            DispatchQueue.main.async {
                self.updateUploadStatus(documentId: document.id, newStatus: .error(message: errorMessage))
                completion(.failure(NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }

        print("🌐 Conectando con \(document.ip):\(document.port)")
        uploader.connectAndSendFile(fileURL: fileURL, to: document.ip, port: document.port)
    }



    func listAllDocumentsInLocalStorage() -> [String] {
        let files = localRepository.listAllDocuments()
        print("📦 [UploadDocumentsViewModel] Archivos en local: \(files)")
        return files
    }

}

enum DocumentUploadStatus: Equatable {
    case available
    case uploading(progress: Int)
    case uploaded
    case error(message: String)
}

