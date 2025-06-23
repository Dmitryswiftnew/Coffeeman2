//
//  MapRouteViewController.swift
//  Coffeeman2
//
//  Created by Dmitry on 23.06.25.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation


class MapRouteViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Запрашиваем разрешение
        case .restricted, .denied:
            // Показываем алерт, что доступ запрещён
            showLocationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Доступ к местоположению запрещён",
                                      message: "Для работы с картой необходимо разрешить доступ к местоположению в настройках.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}
