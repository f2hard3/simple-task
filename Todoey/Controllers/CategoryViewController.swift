//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Sunggon Park on 2024/03/04.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import CoolColourLibrary

class CategoryTableViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("NavagationController does not exist") }
        
        if let backgroundColor = UIColor(hexString: "1D9BF6") {
            navBar.scrollEdgeAppearance?.backgroundColor = backgroundColor
            navBar.tintColor = ContrastColorOf(backgroundColor, isFlat: true)
            navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor, isFlat: true)]
        }
    }

    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            if let categoryColor = UIColor(hexString: category.color) {
                cell.backgroundColor = categoryColor
                cell.textLabel?.textColor = ContrastColorOf(categoryColor, isFlat: true)
            }
        }
        
        return cell
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Create New Category"
            textField = field
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            if let text = textField.text {
                let newCategory = Category()
                newCategory.name = text
                newCategory.color = UIColor.randomFlat().hexValue()
                                
                self.save(category: newCategory)
            }
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    // MARK: - Data Manupulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting categories \(error)")
            }
        }
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destionationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destionationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
}
