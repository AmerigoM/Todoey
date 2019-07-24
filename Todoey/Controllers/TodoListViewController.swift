//
//  ViewController.swift
//  Todoey
//
//  Created by Amerigo Mancino on 13/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    // new instance of realm
    let realm = try! Realm()
    
    // array of items
    var todoItems: Results<Item>?
    
    // the search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // the categories the items are attached to
    var selectedCategory : Category? {
        didSet{
            // this code is triggered as soon as selectedCategory is set with a value
            loadItems()
        }
    }
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
        // Navigation controller might not exist here yet
    }
    
    // called later than viewDidLoad, just before the view is going to be shown up on screen
    override func viewWillAppear(_ animated: Bool) {
        // navigation controller surely exist here

        // change the title of the navigation item
        title = selectedCategory?.name
        
        // set the background of the navbar to be similar to the category color
        guard let colorHex = selectedCategory?.color  else { fatalError() }
        updateNavBar(withHexCode: colorHex)
    }
    
    // the view is just about to be removed
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    // MARK: - NavBar setup code methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        // has the navBar been created?
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        
        // change the navbar color
        navBar.barTintColor = navBarColor
        
        // change the color of the search bar
        searchBar.barTintColor = navBarColor
        
        // apply color to all the objects - buttons, ... - in the navBar
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        // change the navbar text color
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    // MARK: - TableView Datasource Methods
    
    // create and return the single cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cell that was created into the super class
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            // set the title
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:
                CGFloat(indexPath.row) / CGFloat(todoItems!.count)
                ) {
                    // set background color
                    cell.backgroundColor = color
                
                    // change the textcolor according with the background
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
                
            // if the checkmark property is true, a checkmark is displayed
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    // number of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    // MARK: - TableView Delegate Methods
    
    // triggers when a row has been selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // update the object in the database
        
        // if the item at a certain indexpath we're trying to update is not nil
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
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
            
            // if the category is not nil
            if let currentCategory = self.selectedCategory {
                // add item to realm database
                do {
                    try self.realm.write {
                        // create a new item
                        let newItem = Item()
                        
                        // set properties
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        
                        // set relationship
                        currentCategory.items.append(newItem)
                        
                        self.realm.add(newItem)
                    }
                } catch {
                    print("Error saving data, \(error)")
                }
            }
            
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
    
    // MARK: - Model manipulation method
    
    // load all the items from the database
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        // reload the data viewed in the table
        self.tableView.reloadData()
    }

    // MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        // Update the model
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                // delete item
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error in deleting item, \(error)")
            }
        }
    }

}

// MARK: - Search Bar methods
extension TodoListViewController : UISearchBarDelegate {

    // triggers when the user clicked the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // query the database and get back the results the user is searching for
        
        // filter the todo item list using a NSPredicate as for Core Data
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

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

