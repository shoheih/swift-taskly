//
//  TasksController.swift
//  Taskly
//
//  Created by 林将平 on 2019/04/07.
//  Copyright © 2019 Shohei Hayashi. All rights reserved.
//

import UIKit

class TasksController: UITableViewController {
    
    var taskStore: TaskStore! {
        didSet {
            // Get data
            taskStore.tasks = TasksUtility.fetch() ?? [[Task](), [Task]()]
            
            // Reload table view
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        // Setting up our alert controller
        let alertController = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        
        // Set up the actions
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            
            // Crab text field text
            guard let name = alertController.textFields?.first?.text else { return }
            
            // Create task
            let newTask = Task(name: name)
            
            // Add task
            self.taskStore.add(newTask, at: 0)
            
            // Reload data intable view
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add the text field
        alertController.addTextField { textField in
            
            textField.placeholder = "Enter task name..."
            textField.addTarget(self, action: #selector(self.handleTextChanged), for: .editingChanged)
        }
        
        // Add the actions
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        // Present
        present(alertController, animated: true)
    }
    
    @objc private func handleTextChanged(_ sender: UITextField) {
        
        // Grab the alert controller and add action
        guard let alertController = presentedViewController as? UIAlertController,
              let addAction = alertController.actions.first,
              let text = sender.text
              else { return }
        
        // Enable add action base on if text is empty or contains whitespace
        addAction.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
        
        
    }
}

// MARK: - DataSource
extension TasksController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-do" : "Done"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return taskStore.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskStore.tasks[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = taskStore.tasks[indexPath.section][indexPath.row].name
        return cell
    }
    
}

// MARK: - Delegate
extension TasksController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, sourceView, completionHandler) in
            
            // Determin whether the task `isDone`
            guard let isDone = self.taskStore.tasks[indexPath.section][indexPath.row].isDone else { return }
            
            // Remove the task from the appropriate array
            self.taskStore.removeTask(at: indexPath.row, isDone: isDone)
            
            // Reload table view
            tableView.deleteRows(at: [indexPath], with: .automatic)

            // Indicate that action was performed
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let doneAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            
            // Toggle that the task is done
            self.taskStore.tasks[0][indexPath.row].isDone = true
            
            // Remove the task from the array containing tasks
            let doneTask = self.taskStore.removeTask(at: indexPath.row)
            
            // Reload table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Add the task from the array containing tasks
            self.taskStore.add(doneTask, at: 0, isDone: true)
            
            // Reload table view
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            
            // Indicate the action was performed
            completionHandler(true)
        }
        
        doneAction.image = UIImage(named: "done")
        doneAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
}
