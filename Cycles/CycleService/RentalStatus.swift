//
//  RentalResponse.swift
//  Cycles
//

import Foundation
import Kanna

enum RentalStatus: Int, Mappable {
    case NoRental = 1
    case Reserved = 2
    case Rented = 3
    
    static func create(from element: XMLElement, extra: ParameterDict?) -> RentalStatus {
        if
            let stats = element.at_css(".usr_stat"),
            let statsText = stats.text
        {
            if statsText.contains("Reserved") {
                return RentalStatus.Reserved
            }
        }
        return RentalStatus.NoRental
    }
}
