//
//  RentalDetailController.swift
//  Cycles
//

import UIKit

import Moya

protocol RentalDetailDelegate: class {
    func didTapCancel()
}

class RentalDetailViewController: UIViewController {
    var delegate: RentalDetailDelegate?
    var rental: Rental? {
        didSet {
            cyclePort.text = rental?.cyclePort?.name
            cycleID.text = rental?.cycle?.displayName
            expiration.text = rental?.expirationDate.toString(dateFormat: "HH:mm:ss")
            cyclePIN.text = rental?.pin
        }
    }
    
    private var topConstraint: NSLayoutConstraint?

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    private let cycleID: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cyclePort: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cyclePIN: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expiration: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
        
        stack.addArrangedSubview(cyclePort)
        stack.addArrangedSubview(cycleID)
        stack.addArrangedSubview(cyclePIN)
        stack.addArrangedSubview(expiration)
        stack.addArrangedSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(RentalDetailViewController.didTapCancel), for: .touchUpInside)
    }
    
    func setupConstraints() {
        guard let parentView = parent?.view else { return }
        
        stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        view.addConstraints(format: "H:|-20-[v0]-20-|", views: stack)
        
        topConstraint = view.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: -130)
        topConstraint?.isActive = true
        
        parentView.addConstraints(format: "H:|[v0]|", views: view)
        view.heightAnchor.constraint(equalToConstant: 125).isActive = true
    }
    
    @objc private func didTapCancel(_ sender: UIButton) {
        let alert = UIAlertController(title: "Cancel Rental", message: "Are you sure you want to cancel this rental?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Go Back", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Cancel Rental", style: .destructive, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didTapCancel()
        })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.preferredAction = cancel
        self.present(alert, animated: true, completion: nil)
    }
    
    func show() {
        guard let parentView = parent?.view else { return }
        self.topConstraint?.constant = 0
        UIView.animate(
            withDuration: 0.3,
            animations: {
                parentView.layoutIfNeeded()
        })
    }
    
    func hide() {
        guard let parentView = parent?.view else { return }
        self.topConstraint?.constant = -130
        UIView.animate(
            withDuration: 0.3,
            animations: {
                parentView.layoutIfNeeded()
        })
    }
}

// MARK: - Date
extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

// MARK: - UIViewController
extension UIViewController {
    func addDetailController(_ rentalDetailsViewController: RentalDetailViewController) {
        addChild(rentalDetailsViewController)
        rentalDetailsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rentalDetailsViewController.view)
        rentalDetailsViewController.setupConstraints()
    }
}
