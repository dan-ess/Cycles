//
//  UIColor+Cycles.swift
//  Cycles
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        let r = CGFloat(red) / 255
        let g = CGFloat(green) / 255
        let b = CGFloat(blue) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
