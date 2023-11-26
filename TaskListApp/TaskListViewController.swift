//
//  ViewController.swift
//  TaskListApp
//
//  Created by brubru on 23.11.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private let storageManager = StorageManager.shared
    private var task: Task! = nil
	
	private let cellID = "task"
	private var taskList: [Task] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
		view.backgroundColor = .white
		setupNavigationBar()
	}
	
	@objc
	private func addNewTask() {
		showAlert(with: "New Task", and: "What do you want to do?")
	}
}

// MARK: - Private Methods
private extension TaskListViewController {
	func setupNavigationBar() {
		title = "Task List"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		let navBarAppearance = UINavigationBarAppearance()
		navBarAppearance.configureWithOpaqueBackground()
		
		navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
		
		navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
		
		navigationController?.navigationBar.standardAppearance = navBarAppearance
		navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addNewTask)
		)
		
		navigationController?.navigationBar.tintColor = .white
	}
	
	func showAlert(with title: String, and message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
			guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
			save(task)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
		
		alert.addAction(saveAction)
		alert.addAction(cancelAction)
		alert.addTextField { textField in
			textField.placeholder = "NewTask"
		}
		
		present(alert, animated: true)
	}
    
    private func fetchData() {
        storageManager.fetchData { tasks in
            if let firstTask = tasks.first {
                task = firstTask
            }
        }
    }
	
    func save(_ taskName: String) {
        let task = Task(context: storageManager.context)
        task.title = taskName
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        storageManager.saveContext()
    }
    
    func updateTask(_ title: String) {
        
        let indexPath = IndexPath(row: title.count - 1, section: 0)
        let task = taskList[indexPath.row]
        task.title = title
        
        taskList.remove(at: indexPath.row)
        taskList.insert(task, at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        storageManager.update(task)
        
        tableView.reloadData()
    }
}

extension TaskListViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		taskList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		let task = taskList[indexPath.row]
		
		var content = cell.defaultContentConfiguration()
		content.text = task.title
		cell.contentConfiguration = content
        
		return cell
	}
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //StorageManager.shared.deleteTask(task)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
