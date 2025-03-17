import Foundation
import FirebaseStorage

class FileDownloadManager {
    static let shared = FileDownloadManager()
    private let storage = Storage.storage()

    func downloadFileURL(from fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileRef = storage.reference().child(fileName)

        fileRef.downloadURL { url, error in
            if let error = error {
                print("Error getting file URL: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let url = url {
                print("File found: \(url)")
                completion(.success(url))
            }
        }
    }

    func downloadFile(from url: URL, to destinationFileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDir.appendingPathComponent(destinationFileName)

        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let tempURL = tempURL {
                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    completion(.success(destinationURL))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
