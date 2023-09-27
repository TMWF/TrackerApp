import UIKit

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let color: UIColor?
    let emoji: String?
    let schedule: [WeekDay]?
}
