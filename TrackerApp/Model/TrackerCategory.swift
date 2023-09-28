import UIKit

struct TrackerCategory: Hashable {
    let name: String
    let trackers: [Tracker]
    
    func filterTrackers(by name: String, pinned: Bool?) -> [Tracker] {
        if name.isEmpty {
            return pinned == nil ? trackers : trackers.filter { $0.pinned == pinned }
        } else {
            return pinned == nil ? trackers.filter { $0.name.lowercased().contains(name.lowercased()) }
            : trackers
                .filter { $0.name.lowercased().contains(name.lowercased()) }
                .filter { $0.pinned == pinned }
        }
    }
}

