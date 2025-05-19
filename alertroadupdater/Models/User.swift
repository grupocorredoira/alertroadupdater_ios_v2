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
