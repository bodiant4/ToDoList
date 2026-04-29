@testable import ToDoList
import UIKit

// MARK: Mock Interactor
final class MockTaskListInteractor: TaskListInteractorProtocol {
    var fetchAllTasksResult: [Task] = []
    var saveTaskCalled = false
    var updateTaskCalled = false
    var removeTaskCalledWith: UUID?
    var searchTasksResult: [Task] = []
    var taskByIdResult: Task?
    var fetchAPIResult: Result<[Task], Error>?

    func fetchAllTasks(completion: @escaping ([Task]) -> Void) {
        completion(fetchAllTasksResult)
    }

    func saveTask(_ task: Task, completion: @escaping () -> Void) {
        saveTaskCalled = true
        completion()
    }

    func updateTask(_ task: Task, completion: @escaping () -> Void) {
        updateTaskCalled = true
        completion()
    }

    func removeTask(with id: UUID, completion: @escaping () -> Void) {
        removeTaskCalledWith = id
        completion()
    }

    func searchTasks(with query: String, completion: @escaping ([Task]) -> Void) {
        completion(searchTasksResult)
    }

    func task(by id: UUID, completion: @escaping (Task?) -> Void) {
        completion(taskByIdResult)
    }

    func fetchTodosFromAPI(completion: @escaping (Result<[Task], Error>) -> Void) {
        if let result = fetchAPIResult {
            completion(result)
        }
    }
}

// MARK: Mock View
final class MockTaskListView: TaskListViewProtocol {
    var shownTasks: [TaskViewModel] = []
    var shownError: String?
    var isLoading = false
    var shareContent: String?

    func showTasks(_ tasks: [TaskViewModel]) {
        shownTasks = tasks
    }

    func showError(_ message: String) {
        shownError = message
    }

    func showLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

    func presentShareSheet(with content: String) {
        shareContent = content
    }
}

// MARK: Mock Router
final class MockTaskListRouter: TaskListRouterProtocol {
    var openAddDelegate: AddTaskDelegate?
    var openEditTask: Task?
    var openEditDelegate: EditTaskDelegate?

    func openAddTaskScreen(delegate: AddTaskDelegate) {
        openAddDelegate = delegate
    }

    func openEditTaskScreen(for task: Task, delegate: EditTaskDelegate) {
        openEditTask = task
        openEditDelegate = delegate
    }
}
