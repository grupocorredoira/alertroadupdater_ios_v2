import Foundation
import Combine

class UploadDocumentsViewModel: ObservableObject {
    private let localRepository: LocalRepository

    @Published var uploadStates: [String: DocumentUploadStatus] = [:]
    @Published var documents: [Document] = []

    init(localRepository: LocalRepository) {
        self.localRepository = localRepository
        loadDocuments()
    }

    func loadDocuments() {
        documents = FirestoreRepository.allDocuments ?? []
    }

    func updateUploadStatus(documentId: String, newStatus: DocumentUploadStatus) {
        DispatchQueue.main.async {
            self.uploadStates[documentId] = newStatus
        }
    }

    func getDocumentsStoredLocallyForDevice(deviceName: String?) -> [Document] {
        print("📥 Buscando documentos locales para deviceName: '\(deviceName ?? "nil")'")
        for doc in documents {
            let stored = localRepository.isDocumentStored(documentId: doc.id)
            print("➡️ \(doc.deviceName) | ID: \(doc.id) | Guardado localmente: \(stored)")
        }
        let filtered = documents.filter { $0.deviceName == deviceName && localRepository.isDocumentStored(documentId: $0.id) }
        print("✅ Documentos encontrados: \(filtered.count)")
        return filtered
    }


    func uploadDocument(_ document: Document, completion: @escaping (Result<Void, Error>) -> Void) {
        updateUploadStatus(documentId: document.id, newStatus: .uploading(progress: 0))

        DispatchQueue.global(qos: .background).async {
            // Simulación de subida
            for i in stride(from: 0, to: 100, by: 10) {
                sleep(1)
                DispatchQueue.main.async {
                    self.updateUploadStatus(documentId: document.id, newStatus: .uploading(progress: i))
                }
            }

            DispatchQueue.main.async {
                self.updateUploadStatus(documentId: document.id, newStatus: .uploaded)
                completion(.success(()))
            }
        }
    }
}

enum DocumentUploadStatus {
    case available
    case uploading(progress: Int)
    case uploaded
    case error(message: String)
}

