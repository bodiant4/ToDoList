import XCTest
@testable import ToDoList

final class TaskListPresenterTests: XCTestCase {

    var presenter: TaskListPresenter!
    var mockView: MockTaskListView!
    var mockInteractor: MockTaskListInteractor!
    var mockRouter: MockTaskListRouter!

    override func setUp() {
        super.setUp()
        mockView = MockTaskListView()
        mockInteractor = MockTaskListInteractor()
        mockRouter = MockTaskListRouter()
        presenter = TaskListPresenter(interactor: mockInteractor, router: mockRouter)
        presenter.view = mockView
    }

    override func tearDown() {
        presenter = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }
    func testMapToViewModel_FormatsDateCorrectly() {
        let date = Date(timeIntervalSince1970: 1700000000)
        let task = Task(id: UUID(), title: "Test", description: "Desc", creationDate: date, isCompleted: true)
        let tasks = [task]
        mockInteractor.fetchAllTasksResult = tasks
        presenter.viewDidLoad()

        let vm = mockView.shownTasks.first!
        XCTAssertEqual(vm.title, "Test")
        XCTAssertEqual(vm.description, "Desc")
        XCTAssertTrue(vm.isCompleted)
        XCTAssertFalse(vm.formattedDate.isEmpty)
    }

    func testViewDidLoad_NotFirstLaunch_LoadsLocalTasks() {
        UserDefaults.standard.set(true, forKey: "hasLoadedInitialTodos")
        let tasks = [Task(id: UUID(), title: "Test", description: "", creationDate: Date(), isCompleted: false)]
        mockInteractor.fetchAllTasksResult = tasks

        presenter.viewDidLoad()

        XCTAssertFalse(mockView.isLoading)
        XCTAssertEqual(mockView.shownTasks.count, 1)
        XCTAssertEqual(mockView.shownTasks.first?.title, "Test")
    }

    func testSearchTextChanged_CallsSearchWithQuery() {
        let tasks = [Task(id: UUID(), title: "Buy milk", description: "", creationDate: Date(), isCompleted: false)]
        mockInteractor.searchTasksResult = tasks

        presenter.searchTextChanged("milk")

        XCTAssertEqual(mockView.shownTasks.count, 1)
        XCTAssertEqual(mockView.shownTasks.first?.title, "Buy milk")
    }

    func testToggleTaskCompletion_UpdatesAndReloads() {
        let task = Task(id: UUID(), title: "Toggle me", description: "", creationDate: Date(), isCompleted: false)
        mockInteractor.taskByIdResult = task
        mockInteractor.fetchAllTasksResult = [task]

        presenter.toggleTaskCompletion(with: task.id)

        XCTAssertTrue(mockInteractor.updateTaskCalled)
    }

    func testDeleteTask_RemovesTask() {
        let taskId = UUID()
        mockInteractor.fetchAllTasksResult = []

        presenter.deleteTask(with: taskId)

        XCTAssertEqual(mockInteractor.removeTaskCalledWith, taskId)
        XCTAssertEqual(mockView.shownTasks.count, 0)
    }

    func testDidSelectTask_OpensEditScreen() {
        let task = Task(id: UUID(), title: "Edit", description: "", creationDate: Date(), isCompleted: false)
        mockInteractor.taskByIdResult = task

        presenter.didSelectTask(with: task.id)

        XCTAssertNotNil(mockRouter.openEditTask)
        XCTAssertEqual(mockRouter.openEditTask?.title, "Edit")
    }
}
