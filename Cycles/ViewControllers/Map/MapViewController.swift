//
//  MapViewController.swift
//  Cycles
//

import UIKit

import GoogleMaps

public typealias MarkerDict = [String: GMSMarker]

class MapViewController: UIViewController {
    private var apiProvider: ApiProvider
    private var currentArea = CycleServiceArea.中央区
    private var cyclePortViewController: CyclePortViewController?
    private var locationManager = CLLocationManager()
    private var markers = MarkerDict()
    private var mapView: GMSMapView?
    private var presenter: MapPresenter?
    private var userManager: UserManagerProtocol
    private var rentalCache: Cache<Rental>
    private var rentalDetailViewController: RentalDetailViewController?
    private var idleTimer: Timer?
    private var timeoutInSeconds: TimeInterval {
        return 15;
    }
    
    init(
        userManager: UserManagerProtocol,
        apiProvider: ApiProvider,
        rentalCache: Cache<Rental>
    ) {
        if userManager.currentUser == nil {
            fatalError("User is nil")
        }
        self.apiProvider = apiProvider
        self.userManager = userManager
        self.rentalCache = rentalCache
        
        super.init(nibName: nil, bundle: nil)
        
        self.presenter = MapPresenter(
            delegate: self,
            userManager: userManager,
            apiProvider: apiProvider,
            rentalCache: rentalCache
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var topConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        resetIdleTimer()
    }
    
    func setupViews() {
        let cyclePortVC = CyclePortViewController(
            userManager: userManager,
            apiProvider: apiProvider,
            rentalCache: rentalCache
        )
        cyclePortVC.delegate = self
        self.cyclePortViewController = cyclePortVC
        
        let rentalDetailVC = RentalDetailViewController()
        rentalDetailVC.delegate = self
        self.rentalDetailViewController = rentalDetailVC
        
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: UIBarButtonItem.Style.done,
            target: self,
            action: #selector(logoutUser)
        )
        navigationItem.leftBarButtonItem = logoutButton
        
        // set camera to initial location
        let camera = GMSCameraPosition.camera(withLatitude: 35.688038, longitude: 139.786561, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView!.isMyLocationEnabled = true
        mapView!.center = view.center
        mapView!.delegate = self
        view.addSubview(mapView!)
        
        // set camera to user's current location, handle location updates
        // locationManager.delegate = self
        // locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestLocation()

        // let authorizationStatus = CLLocationManager.authorizationStatus()
        // if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
        //   locationManager.requestWhenInUseAuthorization()
        // } else {
        //   locationManager.startUpdatingLocation()
        // }
        
        presenter?.getCyclePorts(for: currentArea)
    }
    
    @objc private func logoutUser(_ sender: UIButton) {
        AppDelegate.shared.rootViewController.switchToLoginScreen()
    }

    override func viewDidAppear(_ animated: Bool) {
        guard
            let cyclePortVC = self.cyclePortViewController,
            let rentalDetailVC = self.rentalDetailViewController
        else {
            fatalError("Could not add controllers to MapViewController")
        }

        addPullUpController(cyclePortVC, animated: true)
        addDetailController(rentalDetailVC)
        
        if
            let rental = rentalCache.load(forKey: Caches.rental.rawValue),
            let rentalDetailViewController = self.rentalDetailViewController
        {
                rentalDetailViewController.rental = rental
                rentalDetailViewController.show()
        }
    }

    private func resetIdleTimer() {
        if idleTimer == nil {
            idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                             target: self,
                                             selector: #selector(MapViewController.idleTimerExceeded),
                                             userInfo: nil,
                                             repeats: false
            )
        } else {
            // extend the timer if ui event happened before idle timeout reset
            if (idleTimer?.fireDate.timeIntervalSinceNow)! < (timeoutInSeconds - 1) {
                idleTimer?.fireDate = NSDate.init(timeIntervalSinceNow: timeoutInSeconds) as Date
            }
        }
    }

    @objc private func idleTimerExceeded() {
        presenter?.getCyclePorts(for: currentArea)
        idleTimer?.invalidate()
        idleTimer = nil
        resetIdleTimer()
    }
    
    override var next: UIResponder? {
        get {
            resetIdleTimer()
            return super.next
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // identify user's initial position and set camera
        if let coordinate: CLLocationCoordinate2D = manager.location?.coordinate {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
                if
                    let address = response?.firstResult(),
                    let locality = address.locality
                {
                    print(locality)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let cyclePort = marker.userData as! CyclePort
        guard let cyclePortVC = self.cyclePortViewController else {
            fatalError("Could not access cyclePortViewController")
        }
        cyclePortVC.show(cyclePort: cyclePort)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard let cyclePortVC = self.cyclePortViewController else {
            fatalError("Could not access cyclePortViewController")
        }
        cyclePortVC.hide()
    }

    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        // update cycle ports if camera has moved to a new area
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { response, error in
            guard error == nil else { return }
            
            if
                let address = response?.firstResult(),
                let locality = address.locality,
                let area = CycleServiceArea.withLabel(locality)
            {
                if self.currentArea != area {
                    self.currentArea = area
                    self.presenter?.getCyclePorts(for: area)
                }
            }
        }
    }
}

// MARK: - RentalDelegate
extension MapViewController: RentalDelegate {
    func didCompleteRental(didCompleteRental rental: Rental) {
        self.rentalDetailViewController?.rental = rental
        self.rentalDetailViewController?.show()
    }
}

// MARK: - RentalDetailDelegate
extension MapViewController: RentalDetailDelegate {
    func didTapCancel() {
        presenter?.cancelRental()
    }
}

// MARK: - MapDelegate
extension MapViewController: MapDelegate {
    func createMarker(cyclePort: CyclePort) -> GMSMarker {
        let lat: Double = Double(cyclePort.parkingLat)!
        let lon: Double = Double(cyclePort.parkingLon)!
        let marker = GMSMarker()
        let markerView = CyclePortMarkerView(cycleCount: cyclePort.cycleCount)
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.iconView = markerView
        marker.title = ""
        marker.snippet = ""
        marker.userData = cyclePort
        return marker
    }

    func didUpdateCyclePorts(cyclePorts: [CyclePort]) {
        for cyclePort in cyclePorts {
            if let marker = markers[cyclePort.formName] {
                if let markerView = marker.iconView as? CyclePortMarkerView {
                    markerView.cycleCount = cyclePort.cycleCount
                }
            } else {
                let marker = createMarker(cyclePort: cyclePort)
                marker.map = mapView!
                markers[cyclePort.formName] = marker
            }
        }
    }

    func didCancelRental() {
        // TODO: it's a little bit difficult to follow how this cancel is called
        // from rental detail -> map -> presenter -> here
        // Consider refactor
        self.rentalDetailViewController?.hide()
    }
}
