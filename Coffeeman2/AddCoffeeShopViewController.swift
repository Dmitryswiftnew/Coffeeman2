//
//  AddCoffeeShopViewController.swift
//  Coffeeman2
//
//  Created by Dmitry on 17.06.25.
//

import UIKit
import CoreData

class AddCoffeeShopViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // список типов кофе
    
    let coffeeTypes = ["Эспрессо", "Американо", "Капучино", "Латте", "Мокко", "Флэт Уайт"]
    // свойства для UIPickerView и UITextField
    
    var typePicker = UIPickerView()// UIPickerView для выбора типа кофе
    var activeTextField: UITextField?  // Текущее активное текстовое поле для связи с UIPickerView
    
    
   
    
    
    // MARK: - Перечисление ячеек
    enum AddPlaceCell: Int, CaseIterable {
        case photo = 0
        case name
        case location
        case type
    }
    
    // MARK: - Свойство для хранения данных формы
    
    var selectedImage:  UIImage? // Выбранное фото кофейни
    var name: String? // Название кофейни
    var location: String?  // Адрес
    var type: String? // Тип кофе
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Place" // Заголовок экрана
        
        
        
        // Добавляем кнопки Cancel и Save в навигационную панель
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        
        tableView.keyboardDismissMode = .onDrag // Скрывать клавиатуру при прокрутке
        
        
        // Регистрируем кастомные ячейки для фото и текстовых полей
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        
        
        // настраиваем UIPickerView
        
        typePicker.dataSource = self
        typePicker.delegate = self
        
 
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AddPlaceCell.allCases.count // Количество ячеек равно числу элементов enum
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
                cell.textField.placeholder = "Тип кофе"
                cell.textField.text = type
                cell.textField.inputView = typePicker // показываем UIPickerView вместо клавиатуры
                
                // Создаём toolbar с кнопкой "Готово"
                   let toolbar = UIToolbar()
                   toolbar.sizeToFit()
                   let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(donePressed))
                   toolbar.setItems([doneButton], animated: false)
                   cell.textField.inputAccessoryView = toolbar
                
                
                cell.onTextChanged = { [weak self] text in
                    self?.type = text
                }
                cell.textField.delegate = self
                return cell
                
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
    
    
    // закрытие пикера для выбора кофе
    
    @objc func donePressed() {
        // получаем выбранную строку в пикере
        
        let selectedRow = typePicker.selectedRow(inComponent: 0)
        // Устанавливаем текст в активное поле и сохраняем выбранный тип
        activeTextField?.text = coffeeTypes[selectedRow]
        type = coffeeTypes[selectedRow]
        
        activeTextField?.resignFirstResponder()
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
        
        dismiss(animated: true) // Закрываем экран без сохранения
    }
    
    
    @objc func saveTapped() {
        
        // Проверяем, что все поля заполнены
        guard let name = name, !name.isEmpty,
              let location = location, !location.isEmpty,
              let type = type, !type.isEmpty else {
            showAlert(message: "Пожалуйста, заполните все поля")
            return
        }
        // Создаём новый объект CoffeeShop в Core Data
        let context = PersistenceManager.shared.context
        let coffeeShop = CoffeeShop(context: context)
        coffeeShop.id = UUID()
        coffeeShop.name = name
        coffeeShop.address = location
        coffeeShop.type = type
        coffeeShop.dateAdded = Date()
        
        
        // Сохраняем фото, если выбрано
        if let image = selectedImage {
            coffeeShop.photoData = image.jpegData(compressionQuality: 0.8)
        }
        
        do {
            try context.save() // Сохраняем в Core Data
            navigationController?.popToRootViewController(animated: true) // Возвращаемся на главный экран
        } catch {
            showAlert(message: "Ошибка сохранения: \(error.localizedDescription)")
        }
        
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert,animated: true)
    }
    

}


// MARK: - Расширение для UIPickerView

extension AddCoffeeShopViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coffeeTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coffeeTypes[row]
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if let textField = activeTextField {
//            textField.text = coffeeTypes[row]
//            type = coffeeTypes[row]
//        }
//    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeTextField?.text = coffeeTypes[row] //  coffeeTypes — ваш массив с типами кофе
        type = coffeeTypes[row] // сохраняем выбранный тип в переменную
    }
    
    
    
}


extension AddCoffeeShopViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField == (tableView.cellForRow(at: IndexPath(row:AddPlaceCell.type.rawValue,section: 0)) as? TextFieldTableViewCell)?.textField {
            // Если поле типа кофе, устанавливаем выбранный элемент в UIPickerView
            if let selectedType = type, let index = coffeeTypes.firstIndex(of: selectedType) {
                typePicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}
