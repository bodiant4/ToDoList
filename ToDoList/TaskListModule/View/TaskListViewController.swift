
import UIKit

final class TaskListViewController: UIViewController {
    
    var presenter: TaskListPresenterProtocol!
    private var tasks: [TaskViewModel] = []
    private var highlightedIndexPath: IndexPath?
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        table.backgroundColor = .black
        table.separatorColor = .darkGray
        table.contentInset.bottom = 60
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Поиск задач"
        sb.barStyle = .black
        sb.searchTextField.textColor = .white
        sb.searchTextField.leftView?.tintColor = .systemYellow
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addTaskButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(bottomBar)
        view.addSubview(activityIndicator)
        
        bottomBar.addSubview(taskCountLabel)
        bottomBar.addSubview(addTaskButton)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 50),
            
            taskCountLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            taskCountLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            
            addTaskButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            addTaskButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            addTaskButton.widthAnchor.constraint(equalToConstant: 44),
            addTaskButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Задачи"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        navigationItem.titleView = titleLabel
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setupActions() {
        addTaskButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
    }
    
    @objc private func addTaskTapped() {
        presenter.addTaskTapped()
    }
    
    private func handleToggleCompletion(at index: Int) {
        let task = tasks[index]
        presenter.toggleTaskCompletion(with: task.id)
    }
    
    private func handleDelete(at index: Int) {
        let task = tasks[index]
        presenter.deleteTask(with: task.id)
    }
    
    private func updateFooter() {
        let total = tasks.count
        let completed = tasks.filter { $0.isCompleted }.count
        taskCountLabel.text = "Выполнено \(completed) из \(total)"
    }
}

// MARK: UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskTableViewCell.identifier,
            for: indexPath
        ) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        cell.configure(with: task, onToggle: { [weak self] in
            self?.handleToggleCompletion(at: indexPath.row)
        })
        return cell
    }
}

// MARK: UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        highlightedIndexPath = indexPath
        let task = tasks[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self?.presenter.didSelectTask(with: task.id)
            }
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self?.presenter.shareTask(with: task.id)
            }
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self?.presenter.deleteTask(with: task.id)
            }
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        if let indexPath = highlightedIndexPath,
           let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
            cell.setStatusButtonHidden(true)
        }
        
        overlayView.isHidden = false
        view.bringSubviewToFront(overlayView)
        UIView.animate(withDuration: 0.2) {
            self.overlayView.alpha = 1.0
        }
    }
    
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        if let indexPath = highlightedIndexPath,
           let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
            cell.setStatusButtonHidden(false)
        }
        highlightedIndexPath = nil
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.overlayView.alpha = 0.0
        } completion: { _ in
            self.overlayView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.handleDelete(at: indexPath.row)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchTextChanged(searchText)
    }
}

// MARK: TaskListViewProtocol
extension TaskListViewController: TaskListViewProtocol {
    func showTasks(_ tasks: [TaskViewModel]) {
        self.tasks = tasks
        tableView.reloadData()
        updateFooter()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func presentShareSheet(with content: String) {
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
