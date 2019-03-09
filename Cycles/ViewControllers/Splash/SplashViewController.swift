//
//  SplashViewController.swift
//  Cycles
//

import UIKit

class SplashViewController: UIViewController {
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private var userManager: UserManagerProtocol
    private var presenter: SplashPresenter?
    
    init(userManager: UserManagerProtocol, apiProvider: ApiProvider) {
        self.userManager = userManager
        super.init(nibName: nil, bundle: nil)
        self.presenter = SplashPresenter(
            delegate: self,
            userManager: userManager,
            apiProvider: apiProvider
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        tryLogin()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.backgroundColor = UIColor(white: 1, alpha: 1)
    }

    func tryLogin() {
        activityIndicator.startAnimating()
        presenter?.login()
    }
}

extension SplashViewController: LoginDelegate {
    func loginDidSucceed() {
        activityIndicator.stopAnimating()
        AppDelegate.shared.rootViewController.switchToMainScreen()
    }
    
    func loginDidFail(message: String?) {
        activityIndicator.stopAnimating()
        AppDelegate.shared.rootViewController.switchToLoginScreen()
    }
}
