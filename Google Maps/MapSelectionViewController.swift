//
//  MapSelectionViewController.swift
//  Coffeeman2
//
//  Created by Dmitry on 23.06.25.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapSelectionController: UIViewController, CLLocationManagerDelegate {
    let locataionManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locataionManager.delegate = self
        locataionManager.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthhorization()
    }
    
    
    
    func checkLocationAuthhorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locataionManager.requestWhenInUseAuthorization() // запрашиваем разрешение
        case .restricted, .denied:
            // Показываем алерт, что доступ запрещён
            showLocationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locataionManager.startUpdatingLocation()
        @unknown default:
            break
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthhorization()
    }
    
    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Доступ к местоположению запрещён", message: "Для работы с картой необходимо разрешить доступ к местоположению в настройках", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Открыт настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
}
