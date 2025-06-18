//
//  AddCoffeeShopViewController.swift
//  Coffeeman2
//
//  Created by Dmitry on 17.06.25.
//

import UIKit
import CoreData

class AddCoffeeShopViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Перечисление ячеек
    enum AddPlaceCell: Int, CaseIterable {
        case photo = 0
        case name
        case location
        case type
    }
    
    // MARK: - Свойство для хранения данных формы
    
    var selectedImage:  UIImage?
    var name: String?
    var location: String?
    var type: String?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Place"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AddPlaceCell.allCases.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = AddPlaceCell(rawValue: indexPath.row)!
        switch cellType {
        case .photo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoTableViewCell
            cell.photoImageView.image = selectedImage ?? UIImage(systemName: "photo")
            return cell
        case .name, .location, .type:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
            
            switch cellType {
            case .name:
                cell.textField.placeholder = "Название кофейни"
                cell.textField.text = name
                cell.onTextChanged = { [weak self] text in
                    self?.name = text
                }
            case .location:
                cell.textField.placeholder = "Адрес"
                cell.textField.text = location
                cell.onTextChanged = { [weak self] text in
                    self?.location = text
                }
                
            case .type:
                cell.textField.placeholder = "Тип кофе"
                cell.textField.text = type
                cell.onTextChanged = { [weak self] text in
                    self?.type = text
                }
                
            default: break
            }
            
            return cell
            
        }
    }
             
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AddPlaceCell(rawValue: indexPath.row) == .photo {
            
            // Вызываем метод показа ActionSheet для выбора фото
            
         showPhotoSourceSelection()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    // Show Photo
    
    func showPhotoSourceSelection() {
        let alert = UIAlertController(title: "Выберите источник фото", message: nil, preferredStyle: .actionSheet)
        
        // проверяем доступность камеры
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
                        self?.presentImagePicker(sourceType: .camera)
                    })
        }
        
        // фото из голереи
        
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default)
                        { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        // отмена
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
        
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Получаем отредактированное фото, если есть, иначе оригинал
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        tableView.reloadRows(at: [IndexPath(row: AddPlaceCell.photo.rawValue, section: 0)], with: .automatic)
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    
    // MARK: - Actions
    
    @objc func cancelTapped() {
    }
    
    
    @objc func saveTapped() {
        guard let name = name, !name.isEmpty,
              let location = location, !location.isEmpty,
              let type = type, !type.isEmpty else {
            showAlert(message: "Пожалуйста, заполните все поля")
            return
        }
        
        let context = PersistenceManager.shared.context
        let coffeeShop = CoffeeShop(context: context)
        coffeeShop.id = UUID()
        coffeeShop.name = name
        coffeeShop.address = location
        coffeeShop.type = type
        coffeeShop.dateAdded = Date()
        
        if let image = selectedImage {
            coffeeShop.photoData = image.jpegData(compressionQuality: 0.8)
        }
        
        do {
            try context.save()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            showAlert(message: "Ошибка сохранения: \(error.localizedDescription)")
        }
        
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert,animated: true)
    }
    

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
