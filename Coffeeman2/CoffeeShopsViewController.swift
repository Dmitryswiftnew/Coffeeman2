//
//  CoffeeShopsViewController.swift
//  Coffeeman2
//
//  Created by Dmitry on 16.06.25.
//

import UIKit
import CoreData

class CoffeeShopsViewController: UITableViewController {
    
    // NSFetchedResultsController для управления выборкой и обновлением таблицы
    var fetchedResultsController: NSFetchedResultsController<CoffeeShop>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Coffeman"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Инициализируем fetchedResultsController
        initializeFetchedResultsController()
        
        // Кнопка "+" для добавления новой кофейни
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCoffeeShop))
        
        tableView.register(CoffeeShopTableViewCell.self, forCellReuseIdentifier: "CoffeeShopCell") // регистрация ячейки
        tableView.rowHeight = 70

    
        
    }
    
   

    // Инициализация NSFetchedResultsController с сортировкой по дате добавления
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
    
    // MARK: - Переход на экран добавления/редактирования кофейни
    
    func showAddEditCoffeeShop(coffeeShop: CoffeeShop? = nil) {
        let addVC = AddCoffeeShopViewController(style: .grouped)
        addVC.coffeeShopToEdit = coffeeShop // передаем объект для редактирования (nil - для нового)
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    
    // Вызов при нажатии на кнопку "+" для добавления новой кофейни
    
    
    @objc func addCoffeeShop() {
        showAddEditCoffeeShop()
    }
    
    
    
    // Вызов при выборе кофейни из списка для редактирования
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coffeeShop = fetchedResultsController.object(at: indexPath)
        showAddEditCoffeeShop(coffeeShop: coffeeShop) // передаем выбранную кофейню для редактирования
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // удаление кофейни по свайпу
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let coffeeShopToDelete = fetchedResultsController.object(at: indexPath)
            
            // получаем контекст Core Data
            let context = PersistenceManager.shared.context
            
        // удаляем объект из контекста
            
            context.delete(coffeeShopToDelete)
            
            do {
                // сохраняем изменения в Core Data
                try context.save()
            } catch {
                print("Ошибка при удалении кофейни: \(error.localizedDescription)")
            }
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
        // Используем кастомную ячейку
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeShopCell", for: indexPath) as! CoffeeShopTableViewCell
        let coffeeShop = fetchedResultsController.object(at: indexPath)
        cell.configure(with: coffeeShop)
        return cell
    }
    
    
}




// MARK: - NSFetchedResultsControllerDelegate - для автоматического обновления таблицы

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
