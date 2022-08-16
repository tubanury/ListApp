//
//  ViewController.swift
//  ListApp
//
//  Created by Tuba N. Yıldız on 13.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
   
    var alertController = UIAlertController()
    var data = [NSManagedObject]()

    
    @IBOutlet weak var tableView: UITableView!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
    }
    
    
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem) {
       
        presentAddAlert()
    }
    
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "Warning!",
                     message: "Delete All Items?",
                     cancelButtonTitle: "Cancel",
                     defaultButtonTitle: "Yes") { _ in
                       
                        let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        
                        let managedObjectContext = appDelegate?.persistentContainer.viewContext
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")

                        // Create Batch Delete Request
                        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        try! managedObjectContext!.execute(batchDeleteRequest)
                        self.fetch()
                        
                    }
    }
    
    func presentAddAlert(){
        
        presentAlert(title: "Add New Item", message: nil, cancelButtonTitle: "Cancel", defaultButtonTitle: "Add", isTextFieldAvailable: true, defaultButtonHandler: { _ in
            let text  = self.alertController.textFields?.first?.text
            if  text != "" {
                //self.data.append((text)!)
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.fetch()
            }
            else{
                self.presentWarningAlert()
            }
        })
        
    }
    
    
    func presentWarningAlert(){
      presentAlert(title: "Warning!", message: "Item name can not be empty.", cancelButtonTitle: "Ok")
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      cancelButtonTitle: String?,
                      defaultButtonTitle: String? = nil,
                      isTextFieldAvailable: Bool =  false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil ){
        
        
        
        
        alertController  = UIAlertController(title: title,
                                                 message: message,
                                                 preferredStyle: preferredStyle)
        
        if defaultButtonTitle != nil {
            
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButton)

        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvailable {
            alertController.addTextField()
            
        }
        

        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
    
}

extension ViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, _ in
        
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            self.presentAlert(title: "Edit Item Name", message: nil, cancelButtonTitle: "Cancel", defaultButtonTitle: "Ok", isTextFieldAvailable: true) { _ in
                let text  = self.alertController.textFields?.first?.text
                if  text != "" {
                    //self.data[indexPath.row] = text!
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    self.fetch()
                }
                else{
                    self.presentWarningAlert()
                }
                
            }
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }

}

