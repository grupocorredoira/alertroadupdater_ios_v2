import Foundation
import FirebaseFirestore
import Combine
/*
class FirestoreRepository: ObservableObject {
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
                        guard let data = try? JSONSerialization.data(withJSONObject: doc.data()),
                              let document = try? JSONDecoder().decode(Document.self, from: data) else {
                            return nil
                        }
                        return document.copy(withID: doc.documentID)
                    } ?? []
                    FirestoreRepository._allDocuments = documents
                    promise(.success(documents))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
*/
