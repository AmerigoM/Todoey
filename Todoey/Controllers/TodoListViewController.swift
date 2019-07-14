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
    
    // create our custom plist object
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
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
        
        saveItems()
        
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
            
            self.saveItems()
            
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
    
    // MARK - Model manipulation method
    
    func saveItems() {
        // create an encoder
        let encoder = PropertyListEncoder()
        
        do {
            // encode the array
            let data = try encoder.encode(itemArray)
            
            // writa encoded data to the specified path
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding array, \(error)")
        }
        
        // reload the TableView to present the new data
        // THIS ACTION IS MANDATORY
        self.tableView.reloadData()
    }
    
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            // create a decoder
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding array, \(error)")
            }
        }
    }
    


}

