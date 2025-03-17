import Foundation
import Combine

class DocumentsViewModel: ObservableObject {
    private let firestoreRepository: FirestoreRepository
    private let localRepository: LocalRepository

    @Published var documents: [Document] = []
    @Published var documentDownloadStates: [String: DocumentDownloadStatus] = [:]

    private var cancellables = Set<AnyCancellable>()

    init(firestoreRepository: FirestoreRepository, localRepository: LocalRepository) {
        self.firestoreRepository = firestoreRepository
        self.localRepository = localRepository
        loadDocumentsFromExternalDatabase()
    }

    private func loadDocumentsFromExternalDatabase() {
        firestoreRepository.loadDocumentsFromFirestore()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading documents: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] fetchedDocuments in
                self?.documents = fetchedDocuments
                self?.initializeDocumentDownloadStates(fetchedDocuments)
            })
            .store(in: &cancellables)
    }

    private func initializeDocumentDownloadStates(_ documents: [Document]) {
        var updatedStates: [String: DocumentDownloadStatus] = [:]
        for document in documents {
            let isStored = localRepository.isDocumentStored(document.id)
            updatedStates[document.id] = isStored ? .downloaded : .available
        }
        documentDownloadStates = updatedStates
    }

    func getAllSSIDs() -> [String] {
        return documents.map { $0.ssid }
    }

    func getPasswordForSSID(ssid: String) -> String? {
        return documents.first { $0.ssid == ssid }?.password
    }

    func downloadFile(documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        documentDownloadStates[documentId] = .downloading(progress: 0)

        FileDownloadManager.downloadFileFromFirebaseStorage(fileName: documentId) { result in
            switch result {
            case .success(let fileUrl):
                FileDownloadManager.downloadFile(fileUrl: fileUrl, fileName: documentId)
                self.documentDownloadStates[documentId] = .downloaded
                completion(.success(()))
            case .failure(let error):
                self.documentDownloadStates[documentId] = .available
                completion(.failure(error))
            }
        }
    }
}

enum DocumentDownloadStatus {
    case available
    case downloaded
    case downloading(progress: Int)
}
