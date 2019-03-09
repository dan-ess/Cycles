//
//  Dictionary+CycleService.swift
//  Cycles
//

import Foundation

extension Dictionary where Key == String, Value == Any? {
    public func urlEncodedString() -> String {
        guard self.count > 0 else { return "" }
        var parts: [String] = []
        for (key, value) in self {
            let v = value ?? ""
            let part = String(
                format: "%@=%@",
                String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                String(describing: v).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part)
        }
        
        return parts.joined(separator: "&")
    }
}
