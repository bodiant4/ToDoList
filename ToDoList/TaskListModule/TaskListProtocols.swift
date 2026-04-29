
import Foundation

// MARK: View Protocol
protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [TaskViewModel])
    func showError(_ message: String)
    func showLoading(_ isLoading: Bool)
    func presentShareSheet(with content: String)
}

// MARK: Presenter Protocol
protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func addTaskTapped()
    func didSelectTask(with id: UUID)
    func deleteTask(with id: UUID)
    func toggleTaskCompletion(with id: UUID)
    func searchTextChanged(_ query: String)
    func shareTask(with id: UUID)
}

// MARK: Interactor Protocol
protocol TaskListInteractorProtocol: AnyObject {
    func fetchTodosFromAPI(completion: @escaping (Result<[Task], Error>) -> Void)
    func fetchAllTasks(completion: @escaping ([Task]) -> Void)
    func saveTask(_ task: Task, completion: @escaping () -> Void)
    func updateTask(_ task: Task, completion: @escaping () -> Void)
    func removeTask(with id: UUID, completion: @escaping () -> Void)
    func searchTasks(with query: String, completion: @escaping ([Task]) -> Void)
    func task(by id: UUID, completion: @escaping (Task?) -> Void)
}

// MARK: Router Protocol
protocol TaskListRouterProtocol: AnyObject {
    func openAddTaskScreen(delegate: AddTaskDelegate)
    func openEditTaskScreen(for task: Task, delegate: EditTaskDelegate)
}

// MARK: Делегаты для обратной связи с экрана создания/редактирования
protocol AddTaskDelegate: AnyObject {
    func didAddTask(_ task: Task)
}

protocol EditTaskDelegate: AnyObject {
    func didUpdateTask(_ task: Task)
}
