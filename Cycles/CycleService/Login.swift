//
//  Login.swift
//  Cycles
//

import Kanna

struct Login: Mappable {
    var sessionID: String?

    static func create(from element: XMLElement, extra: [String : Any?]?) -> Login {
        let sessionID = element["value"]
        return Login(sessionID: sessionID)
    }
}
