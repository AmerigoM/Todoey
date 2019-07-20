//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Amerigo Mancino on 17/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    
    // the realm
    let realm = try! Realm()
    
    // array of categories
    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make the cells 80 points height
        tableView.rowHeight = 80.0
        
        loadCategories()
    }
    
    // MARK: - TableView Datasource Methods
    
    // how the cell look like
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // cell that was created into the super class
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // set the cell with the data grabbed
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        
        // and return
        return cell
        
    }
    
    // number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    // MARK: - Add new categories section
    
    // triggers when the plus button is pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // create the alert window
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        // create a text field
        var textField =  UITextField()
        
        // create an action (a button) to the alert
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            // create new category
            let newCategory = Category()
            newCategory.name = textField.text!
            
            // push it into the database
            self.save(category: newCategory)
        }
        
        // add the text field to the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        // add the action (a button) to the alert
        alert.addAction(action)
        
        // present the alert
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category, \(error)")
        }
        
        // reload the TableView to present the new data
        // THIS ACTION IS MANDATORY
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        // Update the model
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            do {
                // delete item
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error in deleting item, \(error)")
            }
        }
    }
    
    // MARK: - TableView Delegate Methods
    
    // triggers when we select one of the cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // go to the item screen
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // grab a reference to the destination and cast it down to TodoListViewController
        // because we know where the segue is going to end up
        let destinationVC = segue.destination as! TodoListViewController
        
        // if the current row that is selected is not nil
        if let indexPath = tableView.indexPathForSelectedRow {
            // we attach a property to the destination
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
}
