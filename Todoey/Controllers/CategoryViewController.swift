//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Amerigo Mancino on 17/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    // array of categories
    var categoryArray = [Category]()
    
    // Core Data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    // MARK: - TableView Datasource Methods
    
    // how the cell look like
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create the cell for the specific identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // grab the category object for the certain index
        let category = categoryArray[indexPath.row]
        
        // set the cell with the data grabbed
        cell.textLabel?.text = category.name
        
        // and return
        return cell
        
    }
    
    // number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // MARK: - Add new categories section
    
    // triggers when the plus button is pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // create the alert window
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        // create a text field
        var textField =  UITextField()
        
        // create an action (a button) to the alert
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            // create new category
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            
            // append it to the array
            self.categoryArray.append(newCategory)
            
            // push it into the database
            self.saveCategories()
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
    
    func saveCategories() {
        do {
            try self.context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        // reload the TableView to present the new data
        // THIS ACTION IS MANDATORY
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try self.context.fetch(request)
        } catch {
            print("Error fatching data from context, \(error)")
        }
        
        // reload the TableView to present the new data
        // THIS ACTION IS MANDATORY
        self.tableView.reloadData()
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
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
}
