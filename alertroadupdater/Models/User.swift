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
    func toDictionary(includingNil: Bool = false) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard var dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "Encoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir el objeto a diccionario"])
        }

        if includingNil {
            let mirror = Mirror(reflecting: self)
            for child in mirror.children {
                if let label = child.label, child.value is OptionalProtocol, isNil(child.value) {
                    dictionary[label] = NSNull()
                }
            }
        }

        return dictionary
    }

    private func isNil(_ value: Any) -> Bool {
        let mirror = Mirror(reflecting: value)
        return mirror.displayStyle == .optional && mirror.children.count == 0
    }
}

private protocol OptionalProtocol {}
extension Optional: OptionalProtocol {}

