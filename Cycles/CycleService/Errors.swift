//
//  Errors.swift
//  Cycles
//

import Foundation

public enum NetworkError: Error {
    case dataNotEncodable(_: Data, encoding: String.Encoding)
    case htmlParseFailed(_: String)
    case authenticationFailed(_: String)
    case requestErrored(_: String)
}
