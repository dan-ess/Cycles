//
//  LoginViewController.swift
//  Cycles
//

import UIKit

class LoginViewController: UIViewController {
    private var userManager: UserManagerProtocol
    private var presenter: LoginPresenter?
    
    private let stack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // TODO: extract common styles
    private let username: UITextField = {
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        textField.placeholder = "Username"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // TODO: extract common styles
    private let password: UITextField = {
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        textField.placeholder = "Password"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        return button
    }()
    
    init(userManager: UserManagerProtocol, apiProvider: ApiProvider) {
        self.userManager = userManager
        super.init(nibName: nil, bundle: nil)
        self.presenter = LoginPresenter(
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
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(stack)
        view.addConstraints([
            NSLayoutConstraint(item: stack, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -50)
        ])
        view.addConstraints(format: "H:|-30-[v0]-30-|", views: stack)
        
        stack.addArrangedSubview(username)
        stack.addArrangedSubview(password)
        stack.addArrangedSubview(loginButton)

        loginButton.addTarget(self, action: #selector(LoginViewController.didTapLogin), for: .touchUpInside)
    }
    
    @objc func didTapLogin(_ sender: UIButton) {
        presenter?.login(username: username.text!, password: password.text!)
    }
}

extension LoginViewController: LoginDelegate {
    func loginDidSucceed() {
        AppDelegate.shared.rootViewController.switchToMainScreen()
    }
    
    func loginDidFail(message: String?) {
        let alert = UIAlertController(title: "Login failed", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
