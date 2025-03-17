import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class WelcomeViewModel: ObservableObject {
    @Published var firebaseConnected = false
    @Published var userCount: Int = 0
    @Published var fileCount: Int = 0

    func checkFirebaseConnection() {
        let db = Firestore.firestore()

        db.collection("testConnection").document("test").getDocument { _, error in
            DispatchQueue.main.async {
                self.firebaseConnected = (error == nil)
            }
        }
    }


    func fetchUserCount() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error obteniendo usuarios: \(error.localizedDescription)")
                    self.userCount = -1
                } else {
                    self.userCount = snapshot?.documents.count ?? 0
                    print("Número total de usuarios: \(self.userCount)")
                }
            }
        }
    }

    func fetchFileCount() {
        let storageRef = Storage.storage().reference()

        storageRef.listAll { (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error obteniendo archivos de Storage: \(error.localizedDescription)")
                    self.fileCount = -1
                } else if let result = result { // ✅ Desempaquetamos result correctamente
                    self.fileCount = result.items.count
                    print("Número total de archivos en Storage: \(self.fileCount)")
                } else {
                    self.fileCount = 0
                    print("No se encontraron archivos en Storage.")
                }
            }
        }
    }
}
