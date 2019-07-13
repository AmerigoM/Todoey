//
//  ViewController.swift
//  Todoey
//
//  Created by Amerigo Mancino on 13/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK - TableView Datasource Methods
    
    // create and return the single cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    // numebr of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK - TableView Delegate Methods
    
    // triggers when a row has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // print our items list name
        // print(itemArray[indexPath.row])
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            // remove the accessory
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            // put a checkmark as an accessory
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        // the row flashes gray briefly and then goes back to be deselected
        tableView.deselectRow(at: indexPath, animated: true)
    }


}

