//
//  CoffeeShopsViewController.swift
//  Coffeeman2
//
//  Created by Dmitry on 16.06.25.
//

import UIKit
import CoreData

class CoffeeShopsViewController: UITableViewController {
    
    // Объявляем правильное имя переменной
    var fetchedResultsController: NSFetchedResultsController<CoffeeShop>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Coffeman"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        initializeFetchedResultsController()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCoffeeShop))
        
      
        
    
        
    }
    
  
    @objc func addCoffeeShop() {
        let addVC = AddCoffeeShopViewController(style: .grouped)
        navigationController?.pushViewController(addVC, animated: true)
    }

    
    func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CoffeeShop> = CoffeeShop.fetchRequest()
        
        // Правильное имя ключа
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: PersistenceManager.shared.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка загрузки кофеен: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let coffeeShop = fetchedResultsController.object(at: indexPath)
        
        // Отображаем название кофейни
        cell.textLabel?.text = coffeeShop.name
        
        return cell
    }
}




// MARK: - NSFetchedResultsControllerDelegate

extension CoffeeShopsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            break
        }
    }
}
