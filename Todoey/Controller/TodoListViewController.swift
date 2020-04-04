//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    // Only for debugging prupose to get the directory
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(K.itemPropertyList)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    var itemArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCell, for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Item

    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        
        var userInput = UITextField()
        
        let alert = UIAlertController(title: "Add New Toedy Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let input = userInput.text {
                if !input.isEmpty {
                    let newItem = Item(context: self.context)
                    newItem.title = input
                    newItem.done = false
                    newItem.parantCategory = self.selectedCategory!
                    
                    self.itemArray.append(newItem)
                    self.saveItems()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            userInput = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicte: NSPredicate? = nil) {
        do {
            let categoryPredicate = NSPredicate(format: "parantCategory.name MATCHES %@", self.selectedCategory!.name!)
            
            if let additionalPredicate = predicte {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            } else {
                request.predicate = categoryPredicate
            }
            
            itemArray = try context.fetch(request)
        } catch {
            print("\n\nError on fetching Items\n\(error)\n\n")
        }
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // checking the user input at first
        if let userInput = searchBar.text {
            if !userInput.isEmpty {
                // creating new request for fetch
                let request: NSFetchRequest<Item> = Item.fetchRequest()
                
                // It works like 'LIKE' word in SQL
                request.predicate = NSPredicate.init(format: "title CONTAINS[cd] %@", searchBar.text!)
                
                // ordering ASC 'title'
                request.sortDescriptors = [NSSortDescriptor.init(key: "title", ascending: true)]
                
                // padding the request to loadItems
                loadItems(with: request, predicte: request.predicate)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            // now dismissing the keyword
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

