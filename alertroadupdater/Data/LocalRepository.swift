import Foundation

class LocalRepository: ObservableObject {
    private let documentsFolder: URL

    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.documentsFolder = paths[0].appendingPathComponent("Documents")
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
            return fileNames
        } catch {
            print("Error listing documents: \(error.localizedDescription)")
            return []
        }
    }

    func isDocumentStored(documentId: String) -> Bool {
        let fileURL = documentsFolder.appendingPathComponent(documentId)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func deleteAllDocuments() -> DeleteDocumentsResult {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsFolder, includingPropertiesForKeys: nil)
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
