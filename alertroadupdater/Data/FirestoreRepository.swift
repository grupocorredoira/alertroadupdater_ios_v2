import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FirestoreRepository {
    static private var _allDocuments: [Document]?
    private let db = Firestore.firestore()
    private let collectionName = "documents" // FIREBASE_DOCUMENTS_COLLECTION_NAME
    private var cancellables = Set<AnyCancellable>()

    static var allDocuments: [Document]? {
        return _allDocuments
    }

    func loadDocumentsFromFirestore() -> AnyPublisher<[Document], Error> {
        return Future { promise in
            self.db.collection(self.collectionName).getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading documents: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    let documents = snapshot?.documents.compactMap { doc -> Document? in
                        try? doc.data(as: Document.self).copy(withID: doc.documentID)
                    } ?? []
                    FirestoreRepository._allDocuments = documents
                    promise(.success(documents))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
