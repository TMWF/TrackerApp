import Foundation

protocol CategoryListViewModelDelegate: AnyObject {
    func createCategory(category: TrackerCategory)
}

final class CategoryListViewModel: NSObject {
    
    var onChange: (() -> Void)?
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onChange?()
        }
    }

    private let trackerCategoryStore = TrackerCategoryStore()
    private(set) var selectedCategory: TrackerCategory?
    private weak var delegate: CategoryListViewModelDelegate?

    init(delegate: CategoryListViewModelDelegate?, selectedCategory: TrackerCategory?) {
        self.selectedCategory = selectedCategory
        self.delegate = delegate
        super.init()
        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.trackerCategories
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        try? self.trackerCategoryStore.deleteCategory(category)
    }
    
    func selectCategory(with name: String) {
        let category = TrackerCategory(name: name, trackers: [])
        delegate?.createCategory(category: category)
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        onChange?()
    }
}

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.trackerCategories
    }
}
