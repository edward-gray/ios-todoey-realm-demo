//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Edward Gray on 04.04.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeViewController {
    
    //MARK: - Variables
    
    let mRealm = try! Realm()
    var mCategories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
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
                    let newCategory = Category()
                    newCategory.name = input
                    
                    // saving category
                    self.write(errorText: "Error on saving new Category") {
                        self.mRealm.add(newCategory)
                    }
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
        return mCategories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = mCategories?[indexPath.row].name ?? "There is no category"
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
                destinationVC.selectedCategory = self.mCategories?[indexPath.row]
            }
        }
    }
    
    //MARK: - Manipulation methods

    // loading categories
    func loadCategories() {
        self.mCategories = mRealm.objects(Category.self)
        tableView.reloadData()
    }
    
    // writing categories
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
    
    // deleteing category
    override func onSwipeRightAction(at indexPath: IndexPath) {
        if let selectedCategory = self.mCategories?[indexPath.row] {
            self.write(errorText: "Error on deleting category", reload: false) {
                self.mRealm.delete(selectedCategory.items)
                self.mRealm.delete(selectedCategory)
            }
        }
    }
    
    // passing array count to super
    override func getArrayCount() -> Int {
        if let count = mCategories?.count {
            return count * 3
        }
        return 1
    }
}
