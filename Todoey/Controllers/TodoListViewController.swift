//
//  ViewController.swift
//  Todoey
//
//  Created by Amerigo Mancino on 13/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    // the UserDefaults is an interface to interact with the
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Destory Demogorgon"
        itemArray.append(newItem3)
        
        // retrieve the saved data from the UserDefaults
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
    }
    
    // MARK - TableView Datasource Methods
    
    // create and return the single cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        // set the title
        cell.textLabel?.text = item.title
        
        // if the checkmark property is true, a checkmark is displayed
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    // numebr of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // MARK - TableView Delegate Methods
    
    // triggers when a row has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // print our items list name
        // print(itemArray[indexPath.row])
        
        // the done property becomes the opposite of what it currently is
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // reload the TableView to present the new data
        // THIS ACTION IS MANDATORY
        tableView.reloadData()
        
        // the row flashes gray briefly and then goes back to be deselected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK - Add new items section
    
    // triggers when the plus button is pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // local variable of whatever the user typed in the textfield
        var textField = UITextField()
        
        // create an alert
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        // button action that will be added to the altert
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen once the user click the add item button on the UIAlert
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            
            // save the appended item in the UserDefaults
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            // reload the TableView to present the new data
            // THIS ACTION IS MANDATORY
            self.tableView.reloadData()
            
        }
        
        // add the textfield to the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        // add the action to the alert
        alert.addAction(action)
        
        // present the alert
        present(alert, animated: true, completion: nil)
        
    }
    


}

