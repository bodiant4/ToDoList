
import Foundation

final class TaskListPresenter {
    weak var view: TaskListViewProtocol?
    private let interactor: TaskListInteractorProtocol
    private let router: TaskListRouterProtocol
    private var currentQuery: String = ""
    
    init(interactor: TaskListInteractorProtocol, router: TaskListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: Private helpers
    private func loadAndShowTasks() {
        interactor.fetchAllTasks { [weak self] tasks in
            guard let self = self else { return }
            let viewModels = tasks.map { self.mapToViewModel($0) }
            self.view?.showTasks(viewModels)
        }
    }
    
    private func showFilteredTasks() {
        interactor.searchTasks(with: currentQuery) { [weak self] tasks in
            guard let self = self else { return }
            let viewModels = tasks.map { self.mapToViewModel($0) }
            self.view?.showTasks(viewModels)
        }
    }
    
    private func mapToViewModel(_ task: Task) -> TaskViewModel {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let description = task.description.isEmpty ? "Описание отсутствует" : task.description
        return TaskViewModel(
            id: task.id,
            title: task.title,
            description: description,
            formattedDate: formatter.string(from: task.creationDate),
            isCompleted: task.isCompleted
        )
    }
    
    private func handleError(_ message: String) {
        view?.showError(message)
    }
}

// MARK: TaskListPresenterProtocol
extension TaskListPresenter: TaskListPresenterProtocol {
    
    func shareTask(with id: UUID) {
        interactor.task(by: id) { [weak self] task in
            guard let self = self, let task = task else { return }
            let text = "Задача: \(task.title)\nОписание: \(task.description)"
            self.view?.presentShareSheet(with: text)
        }
    }
    
    func viewDidLoad() {
        let hasLoadedKey = "hasLoadedInitialTodos"
        if !UserDefaults.standard.bool(forKey: hasLoadedKey) {
            view?.showLoading(true)
            interactor.fetchTodosFromAPI { [weak self] result in
                self?.view?.showLoading(false)
                switch result {
                case .success(let tasks):
                    let group = DispatchGroup()
                    for task in tasks {
                        group.enter()
                        self?.interactor.saveTask(task) {
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        UserDefaults.standard.set(true, forKey: hasLoadedKey)
                        self?.loadAndShowTasks()
                    }
                case .failure(let error):
                    self?.handleError("Не удалось загрузить задачи: \(error.localizedDescription)")
                    self?.loadAndShowTasks()
                }
            }
        } else {
            loadAndShowTasks()
        }
    }
    
    func addTaskTapped() {
        router.openAddTaskScreen(delegate: self)
    }
    
    func didSelectTask(with id: UUID) {
        interactor.task(by: id) { [weak self] task in
            guard let self = self, let task = task else {
                self?.handleError("Задача не найдена")
                return
            }
            self.router.openEditTaskScreen(for: task, delegate: self)
        }
    }
    
    func deleteTask(with id: UUID) {
        interactor.removeTask(with: id) { [weak self] in
            guard let self = self else { return }
            self.loadAndShowTasks()
        }
    }
    
    func toggleTaskCompletion(with id: UUID) {
        interactor.task(by: id) { [weak self] task in
            guard let self = self, var task = task else {
                self?.handleError("Задача не найдена")
                return
            }
            task.isCompleted.toggle()
            self.interactor.updateTask(task) {
                self.loadAndShowTasks()
            }
        }
    }
    
    func searchTextChanged(_ query: String) {
        currentQuery = query
        showFilteredTasks()
    }
}

// MARK: AddTaskDelegate
extension TaskListPresenter: AddTaskDelegate {
    func didAddTask(_ task: Task) {
        interactor.saveTask(task) { [weak self] in
            guard let self = self else { return }
            self.loadAndShowTasks()
        }
    }
}

// MARK: EditTaskDelegate
extension TaskListPresenter: EditTaskDelegate {
    func didUpdateTask(_ task: Task) {
        interactor.updateTask(task) { [weak self] in
            guard let self = self else { return }
            self.loadAndShowTasks()
        }
    }
}
