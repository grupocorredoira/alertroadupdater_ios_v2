import Foundation

class LocalRepository: ObservableObject {
    private let documentsFolder: URL

    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.documentsFolder = paths[0]
        print("📁 [LocalRepository] Ruta usada para almacenamiento: \(documentsFolder.path)")
        createDocumentsFolderIfNeeded()
    }

    private func createDocumentsFolderIfNeeded() {
        if !FileManager.default.fileExists(atPath: documentsFolder.path) {
            do {
                try FileManager.default.createDirectory(at: documentsFolder, withIntermediateDirectories: true)
            } catch {
                print("Error creating Documents folder: \(error.localizedDescription)")
            }
        }
    }

    func listAllDocuments() -> [String] {
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: documentsFolder.path)
            //print("📄 [LocalRepository] Documentos encontrados en \(documentsFolder.path): \(fileNames)")
            return fileNames
        } catch {
            print("❌ [LocalRepository] Error al listar documentos: \(error.localizedDescription)")
            return []
        }
    }

    func isDocumentStored(documentId: String) -> Bool {
        let fileURL = documentsFolder.appendingPathComponent(documentId)
        let exists = FileManager.default.fileExists(atPath: fileURL.path)
        //print("📂 Verificando existencia del archivo: \(fileURL.path) => \(exists)")
        return exists
    }

    func deleteAllDocuments() -> DeleteDocumentsResult {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsFolder, includingPropertiesForKeys: nil)
            guard !fileURLs.isEmpty else {
                return .noFiles
            }

            var failedFiles = [String]()
            for file in fileURLs {
                do {
                    try FileManager.default.removeItem(at: file)
                } catch {
                    failedFiles.append(file.lastPathComponent)
                }
            }

            return failedFiles.isEmpty ? .success : .error(failedFiles)
        } catch {
            return .error(["Failed to list documents"])
        }
    }


    enum DeleteDocumentsResult {
        case noFiles
        case success
        case error([String])
    }
}
