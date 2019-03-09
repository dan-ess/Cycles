//
//  MarkerView.swift
//  Cycles
//

import UIKit

class CyclePortMarkerView: UIView {
    
    let fillLayer = CAShapeLayer()
    let fillLayer2 = CAShapeLayer()
    let label = UILabel(frame: CGRect(x:0, y:0, width: 40, height: 40))
    let smallCircle = UIBezierPath(
        arcCenter: CGPoint(x: 20, y: 20),
        radius: CGFloat(15), startAngle: CGFloat(0),
        endAngle: CGFloat(Double.pi * 2),
        clockwise: true)
    let bigCircle = UIBezierPath(
        arcCenter: CGPoint(x: 20, y: 20),
        radius: CGFloat(18),
        startAngle: CGFloat(0),
        endAngle: CGFloat(Double.pi * 2),
        clockwise: true)
    var fillColor = UIColor.white
    var borderColor = UIColor.red
    var textColor = UIColor.black
    var cycleCount = "" {
        didSet {
            self.label.text = cycleCount
        }
    }
    
    init(cycleCount: String) {
        self.cycleCount = cycleCount
        super.init(frame: CGRect(x:0, y:0, width:40, height:40))
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
        
        backgroundColor = UIColor.clear
        fillLayer.borderWidth = 3
        fillLayer.strokeColor = UIColor.red.cgColor
        fillLayer.fillColor = UIColor.white.cgColor
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.path = smallCircle.cgPath
        layer.addSublayer(fillLayer)
        
        fillLayer2.borderWidth = 3
        fillLayer2.strokeColor = UIColor.red.cgColor
        fillLayer2.fillColor = UIColor.red.cgColor
        fillLayer2.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer2.path = bigCircle.cgPath
        fillLayer2.isHidden = true
        layer.addSublayer(fillLayer2)
        
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        label.text = self.cycleCount
        label.textAlignment = NSTextAlignment.center
        label.center = CGPoint(x:20, y:20)
        self.addSubview(label)
    }
    
    func select(completion: () -> Void) {
        _select()
        completion()
    }
    
    func _select() {
        // TODO
    }
    
    func deselect() {
        // TODO
    }
}
