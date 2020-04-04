//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Edward Gray on 04.04.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    //MARK: - Variables
    var mCategories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var userInput = UITextField()
        
        // creating new alert
        let alert = UIAlertController.init(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // with text field
        alert.addTextField { (inputTextField) in
            inputTextField.placeholder = "Enter new category name"
            userInput = inputTextField
        }
        
        // adding action
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let input = userInput.text {
                if !input.isEmpty {
                    let newCategory = Category(context: self.context)
                    newCategory.name = input
                    
                    // saving category
                    self.mCategories.append(newCategory)
                    self.save()
                }
            }
        }
        
        // adding action to alert
        alert.addAction(action)
        
        // now peresenting
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCell, for: indexPath)
        cell.textLabel?.text = mCategories[indexPath.row].name
        return cell
    }
    
    //MARK: - Did Select Row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.categorySegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.categorySegue {
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = self.mCategories[indexPath.row]
            }
        }
    }
    
    //MARK: - Manipulation methods

    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            mCategories = try context.fetch(request)
        } catch {
            print("\n\nError on fetching categires\n\(error)\n\n")
        }
        tableView.reloadData()
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("\n\nSaving Category\n\(error)\n\n")
        }
        tableView.reloadData()
    }

}
