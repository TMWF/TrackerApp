import Foundation
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidName
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    var trackers: [Tracker] {
        guard let objects = self.fetchedResultsController.fetchedObjects, let trackers = try? objects.map({ try self.tracker(from: $0)})
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        let context = DatabaseManager.shared.context
        self.init(context: context)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("TrackerStore fetch failed")
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.nameTracker, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        try context.save()
    }
    
    func togglePinTracker(_ tracker: Tracker) throws {
        let tracker = fetchedResultsController.fetchedObjects?.first {
            $0.id == tracker.id
        }
        tracker?.pinned = !(tracker?.pinned ?? false)
        try context.save()
    }
    
    func updateTracker(
        newNameTracker: String,
        newEmoji: String,
        newColor: String,
        newSchedule: [WeekDay],
        categoryName: String,
        editableTracker: Tracker) throws {
            let tracker = fetchedResultsController.fetchedObjects?.first {
                $0.id == editableTracker.id
            }
            tracker?.nameTracker = newNameTracker
            tracker?.emoji = newEmoji
            tracker?.color = newColor
            tracker?.schedule = newSchedule.compactMap { $0.rawValue }
            if (tracker?.category?.nameCategory != categoryName) {
                tracker?.category = TrackerCategoryStore().category(categoryName)
            }
            try context.save()
        }
    
    func deleteTracker(_ trackerToDelete: Tracker) throws {
        let tracker = fetchedResultsController.fetchedObjects?.first {
            $0.id == trackerToDelete.id
        }
        if let tracker {
            context.delete(tracker)
            try context.save()
        }
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.nameTracker = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule?.compactMap { $0.rawValue }
        trackerCoreData.color = tracker.color?.hexString
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackersFromCoreData = try context.fetch(fetchRequest)
        return try trackersFromCoreData.map { try self.tracker(from: $0) }
    }
    
    func tracker(from data: TrackerCoreData) throws -> Tracker {
        guard let name = data.nameTracker,
              let uuid = data.id,
              let emoji = data.emoji,
              let schedule = data.schedule,
              let color = data.color
        else {
            throw DatabaseError.someError
        }
        
        let pinned = data.pinned
        
        return Tracker(
            id: uuid,
            name: name,
            color: color.color,
            emoji: emoji,
            schedule: schedule.compactMap { WeekDay(rawValue: $0) },
            pinned: pinned
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes ?? [],
                deletedIndexes: deletedIndexes ?? [],
                updatedIndexes: updatedIndexes ?? [],
                movedIndexes: movedIndexes ?? []
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let newIndexPath else {
                assertionFailure("Insertion indexPath is unexpectedly nil")
                return
            }
            insertedIndexes?.insert(newIndexPath.item)
        case .delete:
            guard let indexPath else {
                assertionFailure("Deletion indexPath is unexpectedly nil")
                return
            }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath else {
                assertionFailure("Updation indexPath is unexpectedly nil")
                return
            }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let indexPath, let newIndexPath  else {
                assertionFailure("move indexPath is unexpectedly nil")
                return
            }
            movedIndexes?.insert(.init(oldIndex: indexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            assertionFailure("unknown case")
        }
    }
}
