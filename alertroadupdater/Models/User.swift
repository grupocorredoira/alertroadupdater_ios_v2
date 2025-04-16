import Foundation

struct User: Identifiable, Codable {
    var id: String { fullPhoneNumber }
    var fullPhoneNumber: String
    var creationDate: Date
    var expirationDate: Date
    var trialPeriodDays: Int
    var purchaseDate: Date?
    var purchaseToken: String
    var forcePurchase: Bool
}

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "Encoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir el objeto a diccionario"])
        }
        return dictionary
    }
}
