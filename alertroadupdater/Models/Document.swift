import Foundation
import FirebaseFirestoreSwift

struct Document: Identifiable, Codable {
    @DocumentID var id: String?
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

    func toReadableString() -> String {
        return """
        Document:
        ID: \(id ?? "N/A")
        Type: \(type)
        Device Name: \(deviceName)
        Version: \(version)
        SSID: \(ssid)
        Password: \(password)
        IP: \(ip)
        Port: \(port)
        URL: \(url)
        Created At: \(createdAt?.description ?? "N/A")
        Updated At: \(updatedAt?.description ?? "N/A")
        """
    }
}
