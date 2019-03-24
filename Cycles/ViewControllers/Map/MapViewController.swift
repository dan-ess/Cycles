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
    private var idleTimer: Timer?
    private var initialLat = 35.688038
    private var initialLon = 139.786561
    private var locationManager = CLLocationManager()
    private var mapView: GMSMapView?
    private var markers = MarkerDict()
    private var presenter: MapPresenter?
    private var rentalCache: Cache<Rental>
    private var rentalDetailViewController: RentalDetailViewController?
    private var selectedMarker: CyclePortMarkerView?
    private var timeoutInSeconds: TimeInterval {
        return 15;
    }
    private var userManager: UserManagerProtocol
    
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
            rentalDetailViewController.show(animation: false)
        }
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
        let camera = GMSCameraPosition.camera(
            withLatitude: initialLat,
            longitude: initialLon,
            zoom: 16.0
        )
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView!.isMyLocationEnabled = true
        mapView!.settings.myLocationButton = true
        mapView!.center = view.center
        mapView!.delegate = self
        view.addSubview(mapView!)
        
        // try to set camera to user's current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
        
        presenter?.getCyclePorts(for: currentArea)
    }
    
    @objc private func logoutUser(_ sender: UIButton) {
        AppDelegate.shared.rootViewController.switchToLoginScreen()
    }
    
    private func resetIdleTimer() {
        if idleTimer == nil {
            idleTimer = Timer.scheduledTimer(
                timeInterval: timeoutInSeconds,
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
        
        if let rental = rentalCache.load(forKey: Caches.rental.rawValue) {
            presenter?.getRentalStatus()
        }
        
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
    
    func getArea(for location: CLLocationCoordinate2D, completion: @escaping(CycleServiceArea?) -> () ){
        getLocality(for: location) { locality in
            var resolvedArea: CycleServiceArea?
            if
                let locality = locality,
                let area = CycleServiceArea.withLabel(locality)
            {
                resolvedArea = area
            }
            completion(resolvedArea)
        }
    }
    
    func getLocality(for location: CLLocationCoordinate2D, completion: @escaping (String?) -> ()) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(location) { response, error in
            guard error == nil else { return completion("") }
            var resolvedLocality = ""
            if
                let address = response?.firstResult(),
                let locality = address.locality
            {
                resolvedLocality = locality
            }
            completion(resolvedLocality)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // identify user's initial position and set camera
        if let location: CLLocationCoordinate2D = manager.location?.coordinate {
            // update camera
            if let mapView = self.mapView {
                let currentPosition = GMSCameraPosition.camera(
                    withLatitude: location.latitude,
                    longitude: location.longitude,
                    zoom: 16
                )
                mapView.camera = currentPosition
            }
            
            getArea(for: location) { area in
                if
                    let area = area,
                    self.currentArea != area
                {
                    self.currentArea = area
                    self.presenter?.getCyclePorts(for: area)
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
        guard let cyclePort = marker.userData as? CyclePort else {
            fatalError("No userData for cycleport marker")
        }
        
        guard let cyclePortVC = self.cyclePortViewController else {
            fatalError("Could not access cyclePortViewController")
        }
        
        if selectedMarker != nil {
            selectedMarker?.deselect()
        }
        
        if let markerView = marker.iconView as? CyclePortMarkerView {
            markerView.select()
            selectedMarker = markerView
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
        getArea(for: cameraPosition.target) { area in
            if
                let area = area,
                self.currentArea != area
            {
                self.currentArea = area
                self.presenter?.getCyclePorts(for: area)
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
        // TODO: difficult to follow how didCancelRental is called from
        // rental detail -> map -> presenter -> here. Consider refactor
        self.rentalDetailViewController?.hide()
    }
    
    func didUpdateRentalStatus(status: RentalStatus) {
        // hide rental popup if rental no longer exists
        if status == .NoRental {
            rentalCache.clear(forKey: Caches.rental.rawValue)
            self.rentalDetailViewController?.hide()
        }
    }
}
