//
//  MapViewController.swift
//  Cycles
//

import UIKit
import GoogleMaps
import SwiftKeychainWrapper

class MapViewController: UIViewController {
    
    var currentMarker: GMSMarker? = nil
    var currentRental: Rental?
    var cyclePorts: [CyclePort] = []
    var cycleService: CycleService
    var locationManager = CLLocationManager()
    var mapView: GMSMapView?
    var sessionID = ""
    
    var rentalDetailViewController: RentalDetailViewController = {
        let rental = RentalDetailViewController()
        // move height value somewhere
        rental.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 125)
        rental.view.translatesAutoresizingMaskIntoConstraints = false
        rental.view.backgroundColor = .white
        return rental
    }()
    
    var cyclePortViewController: CyclePortViewController = {
        let cyclePort = CyclePortViewController()
        cyclePort.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return cyclePort
    }()
    
    init(cycleService: CycleService = CycleService.shared) {
        self.cycleService = cycleService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.done, target: self, action: #selector(logoutUser))
        navigationItem.leftBarButtonItem = logoutButton
        
        let camera = GMSCameraPosition.camera(withLatitude: 35.688038, longitude: 139.786561, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView!.isMyLocationEnabled = true
        mapView!.center = view.center
        mapView!.delegate = self
        view.addSubview(mapView!)
        
        cyclePortViewController.delegate = self
        rentalDetailViewController.delegate = self

        //            locationManager.delegate = self
        //            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //            locationManager.requestLocation()
        //
        //            let authorizationStatus = CLLocationManager.authorizationStatus()
        //            if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
        //                locationManager.requestWhenInUseAuthorization()
        //            } else {
        //                locationManager.startUpdatingLocation()
        //            }
        
        // find ports by current location
        
        // show ports for location
        //                let camera = GMSCameraPosition.camera(withLatitude: 35.688038, longitude: 139.786561, zoom: 16.0)
        //                self.mapView.frame = CGRect.zero
        //                self.mapView.camera = camera
        
        self.cycleService.getCyclePorts(areaID: "2") { cyclePorts in
            self.cyclePorts = cyclePorts
            for cyclePort in cyclePorts {
                let markerView = CyclePortMarkerView(cycleCount: cyclePort.cycleCount)
                let marker = GMSMarker()
                let lat: Double = Double(cyclePort.parkingLat)!
                let lon: Double = Double(cyclePort.parkingLon)!
                marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                marker.iconView = markerView
                marker.title = ""
                marker.snippet = "Tokyo"
                marker.map = self.mapView!
                marker.userData = cyclePort
            }
        }
    }
    
    @objc private func logoutUser(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: "username")
        KeychainWrapper.standard.removeObject(forKey: "password")
        KeychainWrapper.standard.removeObject(forKey: "sessionID")
        AppDelegate.shared.rootViewController.switchToLoginScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addPullUpController(cyclePortViewController, animated: true)
        addDetailController(rentalDetailViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        if let coordinate: CLLocationCoordinate2D = manager.location?.coordinate {
        //            var geocoder = GMSGeocoder()
        //            geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
        //                if let address = response?.firstResult() {
        //                    print(address.locality)
        //                }
        //            }
        //        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let cyclePort = marker.userData as! CyclePort
        cyclePortViewController.show(cyclePort: cyclePort)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        cyclePortViewController.hide()
    }
}

extension MapViewController: CyclePortDelegate {
    func didCompleteRental(didCompleteRental rental: Rental) {
        currentRental = rental
        self.rentalDetailViewController.rental = rental
        self.rentalDetailViewController.show()
    }
}

extension MapViewController: RentalDetailDelegate {
    func didCompleteCancel(rental: Rental) {
        currentRental = nil
        self.rentalDetailViewController.hide()
    }
}

