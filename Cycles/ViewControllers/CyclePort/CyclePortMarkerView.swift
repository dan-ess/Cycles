//
//  MarkerView.swift
//  Cycles
//

import UIKit

class CyclePortMarkerView: UIView {
    
    let fillLayer = CAShapeLayer()
    let label = UILabel(frame: CGRect(x:0, y:0, width: 40, height: 40))
    let circle = UIBezierPath(
        arcCenter: CGPoint(x: 20, y: 20),
        radius: CGFloat(14),
        startAngle: CGFloat(0),
        endAngle: CGFloat(Double.pi * 2),
        clockwise: true
    )
    var fillColor = UIColor.white
    var textColor = UIColor.black
    var cycleCount = "" {
        didSet {
            self.label.text = cycleCount
        }
    }
    
    init(cycleCount: String) {
        self.cycleCount = cycleCount
        super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // cycle port count marker
        fillLayer.lineWidth = 1
        fillLayer.strokeColor = UIColor.lightGray.cgColor
        fillLayer.fillColor = UIColor.white.cgColor
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.path = circle.cgPath
        
        // cycle port count shadow
        fillLayer.shadowColor = UIColor.gray.cgColor
        fillLayer.shadowOffset = CGSize(width: 0.0, height: 1.5)
        fillLayer.shadowOpacity = 0.4
        fillLayer.shadowRadius = 2
        fillLayer.shouldRasterize = true
        fillLayer.rasterizationScale = UIScreen.main.scale
        
        layer.rasterizationScale = UIScreen.main.scale
        layer.addSublayer(fillLayer)
        
        // cycle port count text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        label.text = self.cycleCount
        label.textAlignment = NSTextAlignment.center
        label.center = CGPoint(x:20, y:20)
        self.addSubview(label)
    }
    
    func select() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.fillLayer.strokeColor = UIColor.gray.cgColor
                self.fillLayer.lineWidth = 2
                self.layoutIfNeeded()
            }
        )
    }
    
    func deselect() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.fillLayer.strokeColor = UIColor.lightGray.cgColor
                self.fillLayer.lineWidth = 1
                self.layoutIfNeeded()
            }
        )
    }
}
