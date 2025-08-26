import Foundation
import FirebaseFirestore
import Combine

class FirestoreRepository: ObservableObject {
    static private var _allDocuments: [Document]?
    private let db = Firestore.firestore()
    private let collectionName = AppConstants.firebaseDocumentsInfoCollectionName
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
                    let documents = snapshot?.documents.compactMap { doc in
                        Document(from: doc)
                    } ?? []
                    
                    FirestoreRepository._allDocuments = documents
                    promise(.success(documents))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
