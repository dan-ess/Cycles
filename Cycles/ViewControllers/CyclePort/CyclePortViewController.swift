//
//  CyclePortViewController.swift
//  Cycles
//

import UIKit

protocol RentalDelegate: class {
    func didCompleteRental(didCompleteRental rental: Rental)
}

class CyclePortViewController: PullUpController {
    var cycles: [Cycle] = [] {
        didSet { cycleTableView.reloadData() }
    }
    var cyclePort: CyclePort?
    weak var delegate: RentalDelegate?
    private var presenter: CyclePortPresenter?

    init(
        userManager: UserManagerProtocol,
        apiProvider: ApiProvider,
        rentalCache: RentalCache
    ) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = CyclePortPresenter(
            delegate: self,
            userManager: userManager,
            apiProvider: apiProvider,
            rentalCache: rentalCache
        )
    }

    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Controls
    private let handleView: UIView = {
        var handle = UIView(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width / 10, height: 10))
        handle.translatesAutoresizingMaskIntoConstraints = false

        var bar = CAShapeLayer()
        bar.fillColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1).cgColor
        bar.strokeColor = UIColor.init(red: 210, green: 210, blue: 210, alpha: 1).cgColor
        bar.lineCap = CAShapeLayerLineCap.round
        bar.lineWidth = 4

        let startPoint = CGPoint(x: -1 * Int(UIScreen.main.bounds.width / 25), y: 0)
        let endPoint = CGPoint(x: Int(UIScreen.main.bounds.width / 25), y: 0)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.stroke()
        bar.path = path.cgPath

        handle.layer.addSublayer(bar)
        return handle
    }()

    private let cyclePortImage: UIImageView  = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "CyclePort"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let countLabel: UILabel = {
        var label = UILabel()
        label.text = ""
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cyclePortContainer: UIView = {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
 
    private let cycleTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let spinner: UIView = {
        let view = UIView()
        
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.color = .lightGray
        
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupViews() {
        view.backgroundColor = .white

        cycleTableView.dataSource = self
        cycleTableView.delegate = self
        cycleTableView.allowsSelection = false
        cycleTableView.register(CycleTableViewCell.self, forCellReuseIdentifier: "cycleCell")

        view.addSubview(handleView)
        view.addSubview(cyclePortContainer)
        view.addSubview(cycleTableView)

        view.addConstraints(format: "V:|-10-[v0]", views: handleView)
        handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        cyclePortContainer.addSubview(cyclePortImage)
        cyclePortContainer.addSubview(titleLabel)
        cyclePortContainer.addSubview(countLabel)
        cyclePortContainer.addSubview(spinner)

        view.addConstraints(format: "V:|-10-[v0(80)]", views: cyclePortContainer)
        view.addConstraints(format: "H:|-20-[v0]-20-|", views: cyclePortContainer)

        cyclePortContainer.addConstraints(format: "H:|[v0(60)]", views: cyclePortImage)
        cyclePortContainer.addConstraints(format: "V:|-10-[v0(70)]", views: cyclePortImage)

        cyclePortContainer.addConstraints(format: "V:|-15-[v0]", views: titleLabel)
        cyclePortContainer.addConstraints(format: "H:|-75-[v0]|", views: titleLabel)

        countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        cyclePortContainer.addConstraints(format: "H:|-75-[v0]|", views: countLabel)

        cyclePortContainer.addConstraints(format: "V:|[v0]|", views: spinner)
        cyclePortContainer.addConstraints(format: "H:|[v0]|", views: spinner)

        cycleTableView.topAnchor.constraint(equalTo: cyclePortImage.bottomAnchor, constant: 20).isActive = true
        view.addConstraints(format: "H:|-5-[v0]-20-|", views: cycleTableView)
        view.addConstraints(format: "V:[v0]|", views: cycleTableView)
    }

    // MARK: - UI Behaviour
    func show(cyclePort: CyclePort) {
        spinner.isHidden = false

        pullUpControllerMoveToVisiblePoint(120, animated: true, completion: nil)

        self.cyclePort = cyclePort
        titleLabel.text = cyclePort.name
        countLabel.text = "\(cyclePort.cycleCount) bikes available"

        presenter?.getCycles(for: cyclePort)
        let urlString = "https://tcc.docomo-cycle.jp/cycle/TYO/\(String(describing: cyclePort.imageUrl))"
        cyclePortImage.loadImageUsingUrlString(urlString: urlString) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.spinner.isHidden = true
        }
    }

    func hide() {
        pullUpControllerMoveToVisiblePoint(0, animated: true, completion: nil)
    }

    // MARK: - PullUpController Overrides
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [CGFloat(120)]
    }

    override var pullUpControllerPreviewOffset: CGFloat {
        // Hide the contoller initially
        return CGFloat(0)
    }

    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 240)
    }
}

extension CyclePortViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cycles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cycleCell", for: indexPath) as! CycleTableViewCell
        cell.cycle = cycles[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension CyclePortViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension CyclePortViewController: CyclePortDelegate {
    func didUpdateCycles(cycles: [Cycle]) {
        self.cycles = cycles
    }
    
    func didCompleteRental(rental: Rental) {
        guard let delegate = delegate else {
            print("invalid rental delegate")
            return
        }
        
        delegate.didCompleteRental(didCompleteRental: rental)
        pullUpControllerMoveToVisiblePoint(0, animated: true, completion: nil)
    }
}

extension CyclePortViewController: CycleCellDelegate {
    func didTapRent(cycle: Cycle) {
        presenter?.rent(cycle: cycle)
    }
}
