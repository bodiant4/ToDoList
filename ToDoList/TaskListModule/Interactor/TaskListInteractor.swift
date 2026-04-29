import CoreData
import Foundation

final class TaskListInteractor: TaskListInteractorProtocol {
    
    private let coreDataStack = CoreDataStack.shared
    
    init() {}
    
    // MARK: Асинхронные методы
    
    func fetchAllTasks(completion: @escaping ([Task]) -> Void) {
        coreDataStack.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            do {
                let entities = try context.fetch(fetchRequest)
                let tasks = entities.map { Task(entity: $0) }
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func saveTask(_ task: Task, completion: @escaping () -> Void) {
        coreDataStack.performBackgroundTask { context in
            let entity = TaskEntity(context: context)
            entity.id = task.id
            entity.title = task.title
            entity.taskDescription = task.description
            entity.creationDate = task.creationDate
            entity.isCompleted = task.isCompleted
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func updateTask(_ task: Task, completion: @escaping () -> Void) {
        coreDataStack.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            do {
                if let entity = try context.fetch(fetchRequest).first {
                    entity.title = task.title
                    entity.taskDescription = task.description
                    entity.creationDate = task.creationDate
                    entity.isCompleted = task.isCompleted
                    try context.save()
                }
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func removeTask(with id: UUID, completion: @escaping () -> Void) {
        coreDataStack.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            do {
                if let entity = try context.fetch(fetchRequest).first {
                    context.delete(entity)
                    try context.save()
                }
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func searchTasks(with query: String, completion: @escaping ([Task]) -> Void) {
        coreDataStack.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            if !query.isEmpty {
                let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@", query, query)
                fetchRequest.predicate = predicate
            }
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            do {
                let entities = try context.fetch(fetchRequest)
                let tasks = entities.map { Task(entity: $0) }
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func task(by id: UUID, completion: @escaping (Task?) -> Void) {
        coreDataStack.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1
            do {
                let entity = try context.fetch(fetchRequest).first
                let task = entity.map { Task(entity: $0) }
                DispatchQueue.main.async {
                    completion(task)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func fetchTodosFromAPI(completion: @escaping (Result<[Task], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TodosResponse.self, from: data)
                let tasks = response.todos.map { Task(from: $0) }
                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
