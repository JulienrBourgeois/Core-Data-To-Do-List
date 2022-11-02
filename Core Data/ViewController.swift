//
//  ViewController.swift
//  Core Data
//
//  Created by Julien Paid Developer on 10/29/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(model.name!) - \(model.createdAt!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        let item = models[indexPath.row]
        
       
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Edit Your Item", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler:
                                            { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else
                {
                    self?.getAllItems()
                    return
                }
                
                
                self?.updateItem(item: item, newName: newName)
                self?.getAllItems()
            }))
            
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
            self?.getAllItems()
        }))

        
        self.present(sheet, animated: true)
       
    }
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var models : [ToDoListItem] = []
    
    let tableView : UITableView =
    {
        let table = UITableView()
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getAllItems()
        
        title = "Core Data To Do List"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTappAdd))
    }
    
    @objc private func didTappAdd()
    {
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler:
                                        { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else
            {
                return
            }
            
            
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }

    
    func getAllItems()
    {
        do
        {
            let items =  try context.fetch(ToDoListItem.fetchRequest())
            models = items
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch
        {
           //error
        }
    }
    
    
    func createItem(name: String)
    {
        let newItem = ToDoListItem(context: context)
        
        newItem.name = name
        newItem.createdAt = Date()
        
        
        do
        {
            try context.save()
            getAllItems()
        }
        catch
        {
            //error
        }
    }
    
    func deleteItem(item: ToDoListItem)
    {
        context.delete(item)
        
        
        do
        {
            try context.save()
        }
        catch
        {
            //error
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String)
    {
        item.name = newName
        
        do
        {
            try context.save()
        }
        catch
        {
            //error
        }
    }

}

