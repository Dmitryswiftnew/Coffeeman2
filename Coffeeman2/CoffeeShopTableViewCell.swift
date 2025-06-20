//
//  CoffeeShopTableViewCell.swift
//  Coffeeman2
//
//  Created by Dmitry on 20.06.25.
//

import Foundation
import UIKit
import CoreData

class CoffeeShopTableViewCell: UITableViewCell {
    
    
    
    
    
    // UIImageView для фото кофейни
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8 // скругление углов
        imageView.backgroundColor = UIColor.systemGray5 // фон для дефолтного состояния
        return imageView
        
    }()
    
    // UILabel для типа кофе
    
    let typeLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.darkGray
        return label
        
    }()
    
    
    
    // UILabel название кофейни
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.label
        return label
        
    }()
    
    
    // UILabel для адреса
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.gray
        label.numberOfLines = 2 // адрес может быть в 2 строки
        return label
    }()
    
    
    // UILabel для иконки информации (Unicode символ ⓘ)
    
    let infoIconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\u{24D8}" // Unicode для ⓘ
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        return label
    }()
    
    // вертикальный стек для текста
    
    private let textStack: UIStackView = {
          let stack = UIStackView()
          stack.axis = .vertical
          stack.spacing = 1
          stack.translatesAutoresizingMaskIntoConstraints = false
          return stack
      }()

    
    
    
    // Инициализатор ячейки
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews() // вызываем настройку UI
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Настройка UI элементов и Auto Layout
    
    private func setupViews() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(infoIconLabel)
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(typeLabel)
        textStack.addArrangedSubview(addressLabel)
        contentView.addSubview(textStack)
        
        
                    
            NSLayoutConstraint.activate([
                        photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                        photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                        photoImageView.widthAnchor.constraint(equalToConstant: 60),
                        photoImageView.heightAnchor.constraint(equalToConstant: 60),

                        infoIconLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                        infoIconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                        infoIconLabel.widthAnchor.constraint(equalToConstant: 24),
                        infoIconLabel.heightAnchor.constraint(equalToConstant: 24),

                        textStack.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 12),
                        textStack.trailingAnchor.constraint(equalTo: infoIconLabel.leadingAnchor, constant: -12),
                        textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)

            
            
        ])
        
    }
    
    // Метод для настройки содержимого ячейки из объекта CoffeeShop
    func configure(with coffeeShop: CoffeeShop) {
        // Если есть фото — показываем его, иначе дефолтное изображение
        if let data = coffeeShop.photoData, let image = UIImage(data: data) {
            photoImageView.image = image
        } else {
            photoImageView.image = UIImage(systemName: "photo")
        }
        
        nameLabel.text = coffeeShop.name ?? "Без названия"
        typeLabel.text = coffeeShop.type?.isEmpty == false ? coffeeShop.type : "Тип не указан"
        addressLabel.text = coffeeShop.address?.isEmpty == false ? coffeeShop.address : "Адрес не указан"
        
    }
    
    
    
    
}
