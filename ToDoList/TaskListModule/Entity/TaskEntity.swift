import Foundation

// MARK: Основная модель задачи
struct Task: Codable {
    /// Уникальный идентификатор, не меняется после создания
    let id: UUID
    /// Название задачи
    var title: String
    /// Описание, может быть пустым
    var description: String
    /// Дата создания
    var creationDate: Date
    /// Статус выполнения
    var isCompleted: Bool

    init(id: UUID = UUID(),
         title: String,
         description: String,
         creationDate: Date = Date(),
         isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.creationDate = creationDate
        self.isCompleted = isCompleted
    }
}

// MARK: Модели ответа от API
struct TodosResponse: Codable {
    let todos: [RemoteTodo]
}
struct RemoteTodo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}

// MARK: Преобразование из RemoteTodo
extension Task {
    init(from remote: RemoteTodo) {
        self.id = UUID()
        self.title = remote.todo
        self.description = ""
        self.creationDate = Date()
        self.isCompleted = remote.completed
    }
}

// MARK: Преобразование из сущности CoreData
extension Task {
    init(entity: TaskEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.description = entity.taskDescription ?? ""
        self.creationDate = entity.creationDate ?? Date()
        self.isCompleted = entity.isCompleted
    }
}
