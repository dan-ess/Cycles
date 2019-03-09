//
//  Response+CycleService.swift
//  Cycles
//

import Foundation
import Kanna
import Moya

protocol Mappable {
    static func create(from element: XMLElement, extra: [String: Any?]?) -> Self
}

extension Response {
    // TODO: support map to single item or list of items
    func mapHTML<M: Mappable>(
        _ type: M.Type,
        atPath path: String,
        encoding: String.Encoding,
        extra: ParameterDict? = nil) throws -> [M]
    {
        guard let html = String(data: data, encoding: encoding) else {
            throw NetworkError.dataNotEncodable(data, encoding: encoding)
        }
        
        guard let doc = try? Kanna.HTML(html: html, encoding: encoding) else {
            throw NetworkError.htmlParseFailed(html)
        }
        
        var mappedItems: [M] = []
        for element in doc.css(path) {
            let item = M.create(from: element, extra: extra)
            mappedItems.append(item)
        }
        return mappedItems
    }
}
