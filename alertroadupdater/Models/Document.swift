import Foundation

struct Document: Identifiable, Codable {
    var id: String
    var type: String
    var deviceName: String
    var version: String
    var ssid: String
    var password: String
    var ip: String
    var port: Int
    var url: String
    var createdAt: Date?
    var updatedAt: Date?

    /// Crea una copia del documento con un nuevo ID.
    func copy(withID newID: String) -> Document {
        return Document(
            id: newID,
            type: self.type,
            deviceName: self.deviceName,
            version: self.version,
            ssid: self.ssid,
            password: self.password,
            ip: self.ip,
            port: self.port,
            url: self.url,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
