
import UIKit

final class TaskListRouter: TaskListRouterProtocol {
    
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        let presenter = TaskListPresenter(interactor: interactor, router: router)
        let view = TaskListViewController()
        
        view.presenter = presenter
        presenter.view = view
        router.viewController = view
        
        return view
    }
    
    // MARK: Открытие экранов
    func openAddTaskScreen(delegate: AddTaskDelegate) {
        let detailVC = TaskDetailViewController()
        detailVC.task = nil
        detailVC.onSave = { [weak delegate] newTask in
            delegate?.didAddTask(newTask)
        }
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func openEditTaskScreen(for task: Task, delegate: EditTaskDelegate) {
        let detailVC = TaskDetailViewController()
        detailVC.task = task
        detailVC.onSave = { [weak delegate] updatedTask in
            delegate?.didUpdateTask(updatedTask)
        }
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
