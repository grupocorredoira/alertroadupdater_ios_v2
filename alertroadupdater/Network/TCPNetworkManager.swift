import Foundation
import Network

class TCPNetworkManager {
    private let serverIP: String
    private let serverPort: Int
    private let uploadFilename: String
    private let progressCallback: ((Int) -> Void)?

    init(serverIP: String, serverPort: Int, uploadFilename: String, progressCallback: ((Int) -> Void)? = nil) {
        self.serverIP = serverIP
        self.serverPort = serverPort
        self.uploadFilename = uploadFilename
        self.progressCallback = progressCallback
    }

/*
    func uploadFile(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    .first!.appendingPathComponent(self.uploadFilename)

                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    completion(.failure(NSError(domain: "FileNotFound", code: 404, userInfo: nil)))
                    return
                }

                let connection = NWConnection(host: NWEndpoint.Host(self.serverIP),
                                              port: NWEndpoint.Port(integerLiteral: UInt16(self.serverPort))!,
                                              using: .tcp)

                connection.start(queue: .global())

                connection.send(content: try Data(contentsOf: fileURL), completion: .contentProcessed { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                    connection.cancel()
                })
            } catch {
                completion(.failure(error))
            }
        }
    }
    */
}
