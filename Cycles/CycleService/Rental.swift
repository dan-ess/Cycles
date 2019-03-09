//
//  RentalResponse.swift
//  Cycles
//

import Foundation
import Kanna

struct Rental: Mappable {
    static let rental_period: Double = 20
    var cycle: Cycle?
    var cyclePort: CyclePort?
    var expirationDate: Date {
        return Date(timeInterval: Rental.rental_period * 60, since: rentalDate!)
    }
    var pin: String
    var rentalDate: Date?

    init(
        rentalDate: Date? = nil,
        cycle: Cycle? = nil,
        cyclePort: CyclePort? = nil,
        pin: String = ""
    ) {
        self.rentalDate = rentalDate
        self.cycle = cycle
        self.cyclePort = cyclePort
        self.pin = pin
    }
    
    static func create(from element: XMLElement, extra: ParameterDict?) -> Rental {
        var rental: Rental = Rental()
        
        if
            let extra = extra,
            let optional = extra["cycle"],
            let unwrapped = optional,
            let cycle = unwrapped as? Cycle
        {
            var pin = ""
            if
                let regex = try? NSRegularExpression(pattern: "[^\\w](\\d{4})", options: []),
                let searchText = element.text,
                let match = regex.firstMatch(
                    in: searchText, options: [],
                    range: NSRange.init(location: 0, length: searchText.count)
                ),
                let range = Range(match.range(at: 1), in: searchText)
            {
                pin = String(searchText[range])
            }

            rental = Rental(rentalDate: Date(), cycle: cycle, cyclePort: cycle.cyclePort, pin: pin)
        } else {
            print("couldn't map rental")
        }
        
        return rental
    }
}
