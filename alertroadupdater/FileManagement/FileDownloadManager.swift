import Foundation
import FirebaseStorage

/// `FileDownloadManager` gestiona la descarga de archivos desde Firebase Storage
/// y su almacenamiento local en el dispositivo.
class FileDownloadManager {

    private static let storage = Storage.storage()

    /// Descarga la URL de un archivo almacenado en Firebase Storage.
    ///
    /// - Parameters:
    ///   - fileName: El nombre exacto del archivo en Firebase Storage.
    ///   - onSuccess: Callback ejecutado cuando se obtiene la URL del archivo.
    ///   - onError: Callback ejecutado en caso de error, devolviendo la excepción correspondiente.
    static func downloadFileFromFirebaseStorage(
        fileName: String,
        onSuccess: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        let fileRef = storage.reference().child(fileName)

        fileRef.downloadURL { url, error in
            if let error = error {
                print("Error al obtener la URL del archivo \(fileName): \(error.localizedDescription)")
                onError(error)
            } else if let url = url {
                print("Archivo encontrado. URL de descarga: \(url.absoluteString)")
                onSuccess(url.absoluteString)
            }
        }
    }

    /// Descarga un archivo desde una URL y lo guarda localmente en el almacenamiento de la aplicación.
    ///
    /// - Parameters:
    ///   - fileName: Nombre con el que se guardará el archivo.
    ///   - fileUrl: URL desde la cual se descargará el archivo.
    ///   - completion: Callback de finalización, con éxito o error.
    static func downloadFileWithURL(
        fileName: String,
        fileUrl: String,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard let url = URL(string: fileUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)

        // Si el archivo ya existe, eliminarlo antes de descargarlo nuevamente
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            do {
                try FileManager.default.removeItem(at: destinationURL)
                print("Archivo existente eliminado: \(destinationURL.path)")
            } catch {
                print("Error al eliminar el archivo existente: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
        }

        let session = URLSession.shared
        let task = session.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                print("Error al descargar \(fileName): \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let tempURL = tempURL else {
                completion(.failure(NSError(domain: "Error: tempURL is nil", code: -1, userInfo: nil)))
                return
            }

            do {
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                print("Archivo descargado y guardado en: \(destinationURL.path)")
                completion(.success(destinationURL))
            } catch {
                print("Error al mover el archivo descargado: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
