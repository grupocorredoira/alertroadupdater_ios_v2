import Foundation
import FirebaseFirestore

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

    /// Inicializa un documento desde un DocumentSnapshot de Firestore.
    init?(from snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else { return nil }

        guard
            let type = data["type"] as? String,
            let deviceName = data["deviceName"] as? String,
            let version = data["version"] as? String,
            let ssid = data["ssid"] as? String,
            let password = data["password"] as? String,
            let ip = data["ip"] as? String,
            let port = data["port"] as? Int,
            let url = data["url"] as? String
        else {
            return nil
        }

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()

        self.init(
            id: snapshot.documentID,
            type: type,
            deviceName: deviceName,
            version: version,
            ssid: ssid,
            password: password,
            ip: ip,
            port: port,
            url: url,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Inicializador completo necesario al definir un init manual
    init(id: String, type: String, deviceName: String, version: String, ssid: String, password: String, ip: String, port: Int, url: String, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.type = type
        self.deviceName = deviceName
        self.version = version
        self.ssid = ssid
        self.password = password
        self.ip = ip
        self.port = port
        self.url = url
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
