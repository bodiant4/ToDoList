
import UIKit

final class TaskDetailViewController: UIViewController {
    
    var task: Task?
    var onSave: ((Task) -> Void)?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 18)
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Название задачи",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = .white
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .black
        tv.layer.borderWidth = 1.0
        tv.layer.borderColor = UIColor.darkGray.cgColor
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Описание задачи"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
        descriptionTextView.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(descriptionPlaceholder)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 5)
        ])
    }
    
    private func populateFields() {
        if let task = task {
            title = "Редактирование"
            titleTextField.text = task.title
            descriptionTextView.text = task.description
            dateLabel.text = "Создана: \(dateFormatter.string(from: task.creationDate))"
            dateLabel.isHidden = false
        } else {
            title = "Новая задача"
            dateLabel.isHidden = true
        }
        updateDescriptionPlaceholder()
    }
    
    @objc private func saveTapped() {
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !titleText.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Введите название", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let descriptionText = descriptionTextView.text ?? ""
        
        let savedTask: Task
        if var existingTask = task {
            existingTask.title = titleText
            existingTask.description = descriptionText
            savedTask = existingTask
        } else {
            savedTask = Task(
                id: UUID(),
                title: titleText,
                description: descriptionText,
                creationDate: Date(),
                isCompleted: false
            )
        }
        
        onSave?(savedTask)
        navigationController?.popViewController(animated: true)
    }
    
    private func updateDescriptionPlaceholder() {
        descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
    }
}

// MARK: UITextViewDelegate
extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateDescriptionPlaceholder()
    }
}
