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
        uploadStates[documentId] = newStatus
    }

    func getDocumentsStoredLocallyForDevice(deviceName: String?) -> [Document] {
        return documents.filter { $0.deviceName == deviceName && localRepository.isDocumentStored($0.id) }
    }
}

enum DocumentUploadStatus {
    case available
    case uploading(progress: Int)
    case uploaded
    case error(message: String)
}
