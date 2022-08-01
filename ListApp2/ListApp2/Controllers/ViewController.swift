//
//  ViewController.swift
//  ListApp2
//
//  Created by Mehmet Ak on 28.07.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    var cellText = [NSManagedObject]()
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
        
    }
    
    @IBAction func AddButtontapped(_ sender: Any) {
        secondPresentAlert(title: "Yeni Eleman Ekle",
                           message: nil,
                           defaultButtonTitle: "Ekle" ,
                           cancelButtonTitle: "Vazgeç",
                           isTextFieldAvaible: true) { _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""{
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
                listItem.setValue(text, forKey: "title")
                try? managedObjectContext?.save()
                self.fetch()}
            else{
                self.presentWorningalert()
            }
        }
    }
    @IBAction func TrashButtonTapped(_ sender: Any) {
        secondPresentAlert(title: "Sil",
                           message: "Tüm öğeler Silinecek",
                           defaultButtonTitle: "Sil",
                           cancelButtonTitle: "Vazgeç",
                           isTextFieldAvaible: false) { _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! managedObjectContext!.execute(batchDeleteRequest)
            self.fetch()
        }
    }
    func presentWorningalert(){
        secondPresentAlert(title: "Uyarı",
                           message: "Boş eleman eklenemez",
                           cancelButtonTitle: "Tamam")
    }
    func secondPresentAlert(title: String? ,
                            message: String? ,
                            PreferredStyle: UIAlertController.Style = .alert ,
                            defaultButtonTitle: String? = nil ,
                            cancelButtonTitle: String?,
                            isTextFieldAvaible: Bool = false,
                            defaultButtonHandler:((UIAlertAction) -> Void)? = nil){
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: PreferredStyle)
        if defaultButtonTitle != nil{
            let defalutButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default ,
                                              handler: defaultButtonHandler)
            alertController.addAction(defalutButton)
        }
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvaible{
            alertController.addTextField()
        }
        
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true)
    }
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        cellText = try! managedObjectContext!.fetch(fetchRequest)
        tableView.reloadData()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath)
        let listItem = cellText[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteRow = UIContextualAction(style: .normal,
                                           title: "Sil") { _, _, _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.cellText[indexPath.row])
            try? managedObjectContext?.save()
            self.fetch()
        }
        let editRow = UIContextualAction(style: .normal,
                                         title: "Düzenle") { _, _, _ in
            self.secondPresentAlert(title: "Düzenle",
                                    message: nil,
                                    defaultButtonTitle: "Kaydet" ,
                                    cancelButtonTitle: "Vazgeç",
                                    isTextFieldAvaible: true) { _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""{
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    self.cellText[indexPath.row].setValue(text, forKey: "title")
                    if managedObjectContext!.hasChanges{
                        try? managedObjectContext?.save()
                    }
                    self.tableView.reloadData()
                }
                else{
                    self.presentWorningalert()
                }
            }
        }
        
        deleteRow.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteRow,editRow])
        return config
    }
    
}


