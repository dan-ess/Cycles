//
//  CycleTableViewCell.swift
//  Cycles
//

import UIKit

protocol CycleCellDelegate {
    func didTapRent(cycle: Cycle)
}

class CycleTableViewCell: UITableViewCell {
    let cycleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var cycle: Cycle? {
        didSet {
            cycleLabel.text = cycle?.displayName
        }
    }
    var delegate: CycleCellDelegate?
    let rentButton: UIButton = {
        var button = UIButton(type: .system)
        button.layer.borderWidth = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Rent", for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setup() {
        contentView.addSubview(cycleLabel)
        contentView.addSubview(rentButton)
        
        cycleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        cycleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        
        rentButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        rentButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        rentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5).isActive = true
        rentButton.addTarget(self, action: #selector(CycleTableViewCell.didTapRent), for: .touchUpInside)
    }
    
    @objc private func didTapRent(_ sender: UIButton) {
        // find the parent window from table cell and notifies parent window view cell was clicked
        var parent: UIView? = sender.superview
        while let v = parent, !v.isKind(of: CycleTableViewCell.self) {
            parent = v.superview
        }
        
        let cycleView: CycleTableViewCell = parent as! CycleTableViewCell
        delegate?.didTapRent(cycle: cycleView.cycle!)
    }
}
