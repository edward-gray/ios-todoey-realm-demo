//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeViewController {
    
    @IBOutlet weak var searchBarView: UISearchBar!
    
    let mRealm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    var todoList: Results<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70.0
        searchBarView.barTintColor = getCustomerColor()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoList?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "Add new item..."
        }
        return cell
    }
    
    //MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoList?[indexPath.row] {
            write {
                item.done = !item.done
                self.mRealm.add(item)
            }
        }
        // removing selected animation for row immidietly after save
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Item

    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        
        var userInput = UITextField()
        
        let alert = UIAlertController(title: "Add New Toedy Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let input = userInput.text {
                if !input.isEmpty {
                    self.write(errorText: "Error on adding new Item to categoty") {
                        let newItem = Item()
                        newItem.title = input
                        self.selectedCategory!.items.append(newItem)
                    }
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            userInput = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    
    // loading items
    func loadItems() {
        todoList = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    // writing item
    func write(errorText errorHandler: String? = "Error on Realm.write", reload: Bool? = true, expression: @escaping () -> Void) {
        do {
            try mRealm.write {
                expression()
            }
        } catch {
            print("\n\n\(errorHandler!)\n\n \(error)")
        }
        
        if reload! {
            tableView.reloadData()
        }
    }
    
    // deleting item
    override func onSwipeRightAction(at indexPath: IndexPath) {
        if let item = self.todoList?[indexPath.row] {
            write(errorText: "Error on deleting the Item", reload: false) {
                self.mRealm.delete(item)
            }
        }
    }
    
    // passing array count to super
    override func getArrayCount() -> Int {
        return todoList?.count ?? 1
    }
    
}

//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // checking the user input at first
        if let userInput = searchBar.text {
            if !userInput.isEmpty {
                print("I was called")
                todoList = todoList?.filter("title CONTAINS[cd] %@", userInput).sorted(byKeyPath: "dataAdded", ascending: true)
                tableView.reloadData()
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

