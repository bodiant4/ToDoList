
import CoreData
@testable import ToDoList

final class TestCoreDataStack {
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "ToDoListModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // в памяти
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { fatalError("Failed to load in-memory store: \(error)") }
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
