import UIKit
import RealmSwift
import CoolColourLibrary

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else { fatalError("NavagationController does not exist") }
            
            if let categoryColor = UIColor(hexString: colorHex) {
                navBar.scrollEdgeAppearance?.backgroundColor = categoryColor
                navBar.tintColor = ContrastColorOf(categoryColor, isFlat: true)
                navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(categoryColor, isFlat: true)]
                
                searchBar.barTintColor = UIColor(hexString: colorHex)
                searchBar.searchTextField.backgroundColor = UIColor(.white)
            }
        }
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            let color = UIColor(hexString: selectedCategory!.color)?.darken(percent: CGFloat(CGFloat(indexPath.row) * 30 / CGFloat(todoItems!.count)))
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color ?? UIColor.randomFlat(), isFlat: true)
            cell.tintColor = ContrastColorOf(color ?? UIColor.randomFlat(), isFlat: true)
            cell.accessoryType = item.done ? .checkmark :  .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error updating done status \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error adding new items \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDelettion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDelettion)
                }
            } catch {
                print("Error delete items \(error)")
            }
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
