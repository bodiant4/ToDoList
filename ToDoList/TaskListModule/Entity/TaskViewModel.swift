
import Foundation

struct TaskViewModel {
    /// Уникальный идентификатор задачи
    let id: UUID
    /// Название задачи
    let title: String
    /// Описание (может быть пустым или значением по умолчанию)
    let description: String
    /// Дата создания в формате, готовом для отображения (например, "01.01.2024 12:30")
    let formattedDate: String
    /// Выполнена задача или нет
    let isCompleted: Bool
}
