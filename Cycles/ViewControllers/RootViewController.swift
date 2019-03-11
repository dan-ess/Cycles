//
//  RootViewController.swift
//  Cycles
//

import UIKit

// overrides the root view controller to handle logged in / not logged-in user
class RootViewController: UIViewController {
    private var apiProvider: ApiProvider
    private var current: UIViewController
    private var userManager: UserManagerProtocol
    private var rentalCache: RentalCache
    
    init(
        userManager: UserManagerProtocol,
        apiProvider: ApiProvider,
        rentalCache: RentalCache
    ) {
        self.apiProvider = apiProvider
        self.userManager = userManager
        self.rentalCache = rentalCache
        
        self.current = SplashViewController(
            userManager: userManager,
            apiProvider: apiProvider
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        current.view.frame = view.bounds
        add(current)
    }
    
    func switchToMainScreen() {
        if userManager.currentUser == nil {
            assertionFailure("currentUser instance was not set")
            return
        }
        
        let mapViewController = MapViewController(
            userManager: userManager,
            apiProvider: apiProvider,
            rentalCache: rentalCache
        )
        let mainScreen = UINavigationController(rootViewController: mapViewController)
        mainScreen.navigationBar.topItem?.title = "Cycles"
        mainScreen.view.bounds = view.bounds
        switchChild(to: mainScreen)
    }
    
    func switchToLoginScreen() {
        let loginViewController = LoginViewController(
            userManager: userManager,
            apiProvider: apiProvider
        )
        loginViewController.view.frame = view.bounds
        switchChild(to: loginViewController)
    }
    
    func switchChild(to child: UIViewController) {
        add(child)
        current.remove()
        current = child
    }
    
    func logoutUser() {
        switchToLoginScreen()
    }
}

// MARK: - UIViewController
extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
