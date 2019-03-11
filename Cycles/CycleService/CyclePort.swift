//
//  CyclePort.swift
//  Cycles
//

import Kanna

public struct CyclePort: Mappable, Codable {
    var name: String
    var formName: String
    var parkingEntID: String
    var parkingID: String
    var parkingLat: String
    var parkingLon: String
    var cycleCount: String
    var imageUrl: String
    
    static func create(from element: XMLElement, extra: ParameterDict?) -> CyclePort {
        var cyclePortDict = ParameterDict()
        let locationName = element.at_css("a")?.at_xpath("text()[1]")?.text
        var imageUrl = ""
        if let image = element.at_css(".port_list_btn > img") {
            imageUrl = image["src"] ?? ""
        }

        cyclePortDict["formName"] = element["name"]
        
        for input in element.css("input") {
            cyclePortDict[input["name"]!] = input["value"]
        }
        
        if
            let regex = try? NSRegularExpression(pattern: "([0-9]+)台</a>", options: .caseInsensitive),
            let formText = element.innerHTML,
            let match = regex.firstMatch(
                in: formText, options: [],
                range: NSRange(location: 0, length: formText.count)
            ),
            let range = Range(match.range(at: 1), in: formText)
        {
            cyclePortDict["cycleCount"] = String(formText[range])
        } else {
            cyclePortDict["cycleCount"] = "0"
        }
        
        let cyclePort = CyclePort(
            name: locationName ?? "",
            formName: cyclePortDict["formName"] as? String ?? "",
            parkingEntID: cyclePortDict["ParkingEntID"] as? String ?? "",
            parkingID: cyclePortDict["ParkingID"] as? String ?? "",
            parkingLat: cyclePortDict["ParkingLat"] as? String ?? "",
            parkingLon: cyclePortDict["ParkingLon"] as? String ?? "",
            cycleCount: cyclePortDict["cycleCount"] as? String ?? "",
            imageUrl: imageUrl
        )
        
        return cyclePort
    }
}
