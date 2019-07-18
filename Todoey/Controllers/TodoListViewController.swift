//
//  ViewController.swift
//  Todoey
//
//  Created by Amerigo Mancino on 13/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet{
            // this code is triggered as soon as selectedCategory is set with a value
            loadItems()
        }
    }
    
    // get context for Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print path to database
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    // MARK: - TableView Datasource Methods
    
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
    
    // number of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // MARK: - TableView Delegate Methods
    
    // triggers when a row has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // update the object in the database
        
        // the done property becomes the opposite of what it currently is
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        // the row flashes gray briefly and then goes back to be deselected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add new items section
    
    // triggers when the plus button is pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // local variable of whatever the user typed in the textfield
        var textField = UITextField()
        
        // create an alert
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        // button action that will be added to the altert
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen once the user clicks the add item button on the UIAlert
            
            // create a new item
            let newItem = Item(context: self.context)
            // set properties
            newItem.title = textField.text!
            newItem.done = false
            // set relations
            newItem.parentCategory = self.selectedCategory
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
    
    // MARK: - Model manipulation method
    
    func saveItems() {
        do {
            try self.context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        // reload the TableView to present the new data
        // THIS ACTION IS MANDATORY
        self.tableView.reloadData()
    }
    
    
    // load all the items from the database if no parameters are passed or fetch the specific request
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        
        // we load only the items that have the selected category
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        // if the predicate passed by argument is not nil
        if let additionalPredicate = predicate {
            // filter by category and search bar
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        } else {
            // filter by category only
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try self.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        // reload the data viewed in the table
        self.tableView.reloadData()
    }


}

// MARK: - Search Bar methods
extension TodoListViewController : UISearchBarDelegate {

    // triggers when the user clicked the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // query the database and get back the results the user is searching for
        
        // create the request
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // create the predicate to fetch specific data and attach it to the request
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // sort data we get back from the database by title with ascending order and attach sortDescriptor to the request
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // run the request
        loadItems(with: request, predicate: predicate)
        
    }
    
    // triggers when the text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // if the text changes to be empty (= if the user click the cross button in the field)
        if searchBar.text?.count == 0 {
            // we load all the items again with no filters
            loadItems()
            
            /** Note Amerigo Mancino 17.07.2019
             *  All the functions that modifies the user interface must run
             *  in the main thread (in the foreground) to be visible otherwise
             *  the app will appear sluggish or broken to the user
             */
            
            // grab the main thread
            DispatchQueue.main.async {
                // the searchbar will lose the focus and the the keyboard is dismissed
                searchBar.resignFirstResponder()
            }

        }
    }
    
}

