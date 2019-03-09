//
//  Cycle.swift
//  Cycles
//

import Kanna

public struct Cycle: Mappable {
    var displayName: String
    var cycleEntID: String
    var cycleID: String
    var centerLat: String
    var centerLon: String
    var cycLat: String
    var cycLon: String
    var attachID: String
    var cycleTypeNo: String
    var cyclePort: CyclePort
    
    static func create(from element: XMLElement, extra: ParameterDict?) -> Cycle {
        var cycleDict = ParameterDict()
        var cyclePort = CyclePort(
            name: "",
            formName: "",
            parkingEntID: "",
            parkingID: "",
            parkingLat: "",
            parkingLon: "",
            cycleCount: "",
            imageUrl: "")
        
        for input in element.css("input") {
            cycleDict[input["name"]!] = input["value"]
        }
        
        if
            let extra = extra,
            let optional = extra["cyclePort"],
            let unwrapped = optional, let value = unwrapped as? CyclePort
        {
            cyclePort = value
        }
        
        let displayNameElement = element.at_css(".cycle_list_btn a")?.text
        
        let cycle = Cycle(
            displayName: displayNameElement ?? "",
            cycleEntID: cycleDict["CycleEntID"] as? String ?? "",
            cycleID: cycleDict["CycleID"] as? String ?? "",
            centerLat: cycleDict["CenterLat"] as? String ?? "",
            centerLon: cycleDict["CenterLon"] as? String ?? "",
            cycLat: cycleDict["CycLat"] as? String ?? "",
            cycLon: cycleDict["CycLon"] as? String ?? "",
            attachID: cycleDict["AttachID"] as? String ?? "",
            cycleTypeNo: cycleDict["CycleTypeNo"] as? String ?? "",
            cyclePort: cyclePort)
        
        return cycle
    }
}
