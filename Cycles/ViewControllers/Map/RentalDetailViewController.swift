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
            cyclePortLabel.text = rental?.cyclePort?.name
            cycleLabel.text = "\(rental?.cycle?.displayName ?? "") / \(rental?.pin ?? "")"
            expirationLabel.text = "until \(rental?.expirationDate.toString(dateFormat: "HH:mm:ss") ?? "")"
        }
    }
    
    private var topConstraint: NSLayoutConstraint?

    private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 0
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    private let successLabel: UILabel = {
        let label = UILabel()
        label.text = "Cycle reserved"
        label.mask?.isHidden = true
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private let cyclePortLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let cycleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.textAlignment = .right
        return label
    }()
    
    private let successImageView: UIImageView = {
        let image = UIImage(named: "success")
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .darkGray
        return imageView
    }()
    
    private let markerImageView: UIImageView = {
        let image = UIImage(named: "marker")
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .darkGray
        return imageView
    }()
    
    private let cycleImageView: UIImageView = {
        let image = UIImage(named: "cycle")
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .darkGray
        return imageView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        let header = UIView()
        view.addSubview(header)
        view.addConstraints(format: "H:|[v0]|", views: header)
        
        header.addSubview(successImageView)
        header.addSubview(successLabel)
        header.addSubview(expirationLabel)
        header.addConstraints(format: "H:|-12-[v0(25)]-[v1]-[v2(90)]-15-|", views: successImageView, successLabel, expirationLabel)
        header.addConstraints(format: "V:|[v0(25)]", views: successImageView)
        header.addConstraints(format: "V:|[v0]", views: successLabel)
        header.addConstraints(format: "V:|[v0(24)]", views: expirationLabel)
        successImageView.centerYAnchor.constraint(equalTo: successLabel.centerYAnchor).isActive = true
        
        let body1 = UIView()
        view.addSubview(body1)
        view.addConstraints(format: "H:|[v0]|", views: body1)
        
        body1.addSubview(markerImageView)
        body1.addSubview(cyclePortLabel)
        body1.addConstraints(format: "H:|-16-[v0(18)]-[v1]-|", views: markerImageView, cyclePortLabel)
        body1.addConstraints(format: "V:[v0(18)]", views: markerImageView)
        body1.addConstraints(format: "V:|[v0]|", views: cyclePortLabel)
        markerImageView.centerYAnchor.constraint(equalTo: cyclePortLabel.centerYAnchor).isActive = true
        
        let body2 = UIView()
        view.addSubview(body2)
        view.addConstraints(format: "H:|[v0]|", views: body2)
        
        body2.addSubview(cycleImageView)
        body2.addSubview(cycleLabel)
        body2.addSubview(cancelButton)
        body2.addConstraints(format: "H:|-16-[v0(18)]-[v1][v2]-15-|", views: cycleImageView, cycleLabel, cancelButton)
        body2.addConstraints(format: "V:[v0(18)]", views: cycleImageView)
        body2.addConstraints(format: "V:|[v0]|", views: cycleLabel)
        body2.addConstraints(format: "V:|[v0]|", views: cancelButton)
        cycleImageView.centerYAnchor.constraint(equalTo: cycleLabel.centerYAnchor).isActive = true
        
        view.addConstraints(format: "V:|-12-[v0(26)]-3-[v1(24)][v2(24)]", views: header, body1, body2)
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100),
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 10, height: 10)
        ).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = 3
        
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 10.0
        view.layer.insertSublayer(shadowLayer, at: 0)
        
        cancelButton.addTarget(self, action: #selector(RentalDetailViewController.didTapCancel), for: .touchUpInside)
    }
    
    func setupConstraints() {
        guard let parentView = parent?.view else { return }
        
        topConstraint = view.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: -105)
        topConstraint?.isActive = true
        
        parentView.addConstraints(format: "H:|[v0]|", views: view)

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
    
    func show(animation: Bool = true) {
        guard let parentView = parent?.view else { return }
        self.topConstraint?.constant = 0
        if animation {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    parentView.layoutIfNeeded()
            })
        }
    }
    
    func hide() {
        guard let parentView = parent?.view else { return }
        self.topConstraint?.constant = -105
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
