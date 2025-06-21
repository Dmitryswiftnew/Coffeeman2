//
//  StarRatingView.swift
//  Coffeeman2
//
//  Created by Dmitry on 21.06.25.
//

import Foundation
import UIKit
import CoreData

protocol StarRatingViewDelegate: AnyObject {
    func starRatingView(_ starRatingView: StarRatingView, didUpdate rating: Int)
}

class StarRatingView: UIView {
    
    var isEditable: Bool = true {
        didSet {
            updateUserInteraction()
        }
    }
    
    // Массив UIImageView для звезд
    
    private var starImageViews: [UIImageView] = []
    
    
    // макс. кол. звезд
    
    private let maxStars = 5
    
    // текущий рейтинг (0...5)
    
    var rating: Int = 0 {
        didSet {
            updateStars()
            
        }
    }
    
    // делегат для уведомления об изменени рейтинга
    weak var delegate: StarRatingViewDelegate?
    
   
    
    // Инициализаторы
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }
    
    // Создаём UIImageView для каждой звезды и добавляем их в стек
    private func setupStars() {
        // UIStackView для удобного расположения
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        
        // Создаём звёзды
        
        for _ in 0..<maxStars {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemYellow
            
            //  фиксированный размер для звезды
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            imageView.image = UIImage(systemName: "star") // пустая звезда
            imageView.isUserInteractionEnabled = true
            stack.addArrangedSubview(imageView)
            starImageViews.append(imageView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleStarTap(_:)))
            imageView.addGestureRecognizer(tap)
            starImageViews.append(imageView)
            
        }
        updateUserInteraction()
        updateStars()
        
        
    }
    
   

    private func updateUserInteraction() {
        for star in starImageViews {
            star.isUserInteractionEnabled = isEditable
        }
    }
    
    
//    private func updateUserInteraction() {
//           for (index, star) in starImageViews.enumerated() {
//               star.isUserInteractionEnabled = isEditable
//               // Включаем или выключаем распознавание жестов
//               if isEditable {
//                   if star.gestureRecognizers?.contains(tapGestureRecognizers[index]) == false {
//                       star.addGestureRecognizer(tapGestureRecognizers[index])
//                   }
//               } else {
//                   if let tap = tapGestureRecognizers[index] as? UITapGestureRecognizer {
//                       star.removeGestureRecognizer(tap)
//                   }
//               }
//           }
//       }
    
    
    
    
    
    // Обновляем отображение звёзд в зависимости от рейтинга
    
    private func updateStars() {
        for (index, imageView) in starImageViews.enumerated() {
            if index < rating {
                imageView.image = UIImage(systemName: "star.fill")
            } else {
                imageView.image = UIImage(systemName: "star")
            }
        }
        
    }
    
    
    // Обработка нажатия на звезду
    
    @objc private func handleStarTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedStar = gesture.view as? UIImageView,
              let index = starImageViews.firstIndex(of: tappedStar) else { return }
        
        if rating == index + 1 {
            // Если тапнули на текущую последнюю заполненную звезду — сбрасываем рейтинг
            rating = 0
        } else {
            // Иначе устанавливаем рейтинг по индексу
            rating = index + 1
        }
       
        
        // // Уведомляем делегата
        delegate?.starRatingView(self, didUpdate: rating)
        
    }
    
    
    
}
