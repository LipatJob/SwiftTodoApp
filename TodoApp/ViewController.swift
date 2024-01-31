//
//  ViewController.swift
//  TodoApp
//
//  Created by Job Lipat on 1/31/24.
//

import UIKit

class ViewController: UIViewController {
    var todoItems: [TodoItem] = []
    
    @IBOutlet weak var todoListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.todoListTableView.dataSource = self
        self.todoListTableView.delegate = self
    }
    
    enum TodoInputType {
        case create
        case update
    }
    
    func getTodoItemFromUser( defaultValue: String = "", type: TodoInputType, onInput: @escaping (String) -> Void){
        let message = switch type
        {
            case .create: "Create Todo Item"
            case .update: "Update Todo Item"
        }
        
        let alertController = UIAlertController(
            title: "Todo Item",
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addTextField{textField in
            textField.placeholder = "Description of todo item"
            textField.text = defaultValue
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(
            title: "Ok",
            style: .default,
            handler: {[weak alertController] _ in
                if
                    let textField = alertController?.textFields?.first,
                    let enteredText = textField.text
                {
                    print(enteredText)
                    onInput(enteredText)
                    
                }}
        )
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
           
        self.present(alertController, animated: true)
        
    }
    
    @IBAction func onAddButtonClicked(_ sender: Any) {
        getTodoItemFromUser(type: .create) { enteredText in
            let newItem = TodoItem(
                identifier: UUID().uuidString,
                description: enteredText,
                isDone: false
            )
            self.todoItems.append(newItem)
            self.todoListTableView.reloadData()
        }
    }
}


struct TodoItem{
    let identifier: String
    let description: String
    let isDone: Bool
}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "TodoItem"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TodoItemTableViewCell
        let todoItem = self.todoItems[indexPath.row]
        cell?.bind(todoItem, delegate: self)

        return cell ?? UITableViewCell()
    }
}

extension ViewController :TodoItemTableViewCellDelegate{
    func updateTodoItem(identifier: String, newValue: TodoItem) {
        todoItems = todoItems.map({todoItem in
            if todoItem.identifier == identifier {
                return newValue
            }
            return todoItem
        })
        self.todoListTableView.reloadData()
    }
}

extension ViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoItem = self.todoItems[indexPath.row]
        getTodoItemFromUser(
            defaultValue: todoItem.description,
            type: .update,
            onInput: { enteredText in
                self.updateTodoItem(
                    identifier: todoItem.identifier,
                    newValue: TodoItem(
                        identifier: todoItem.identifier,
                        description: enteredText,
                        isDone: todoItem.isDone))
                self.todoListTableView.reloadData()
            }
        )
        self.todoListTableView.reloadData()
    }
}


protocol TodoItemTableViewCellDelegate :AnyObject {
    func updateTodoItem(identifier: String, newValue: TodoItem)
}

internal class TodoItemTableViewCell : UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var statusButton: UIButton!
    
    private var todoItem: TodoItem?
    
    private weak var delegate: TodoItemTableViewCellDelegate?
    
    func bind(_ item: TodoItem, delegate: TodoItemTableViewCellDelegate){
        let buttonImage = UIImage(named: item.isDone ? "buttonActive" : "buttonInactive")
        
        self.todoItem = item
        self.delegate = delegate
        self.titleLabel.text = item.description
        self.statusButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func onToggleClicked(_ sender: Any) {
        let newStatus = !todoItem!.isDone
        delegate?.updateTodoItem(
            identifier: todoItem!.identifier,
            newValue: TodoItem(
                identifier: todoItem!.identifier,
                description: todoItem!.description,
                isDone: newStatus
            )
        )
    }
}
