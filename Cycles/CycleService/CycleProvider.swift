//
//  CycleProvider.swift
//  Cycles
//

import Moya

typealias ApiProvider = MoyaProvider<CycleService>

extension MoyaProvider where Target == CycleService {
    func _request<MapTo: Mappable>(
        for endpoint: CycleService,
        atPath: String,
        success successCallback: @escaping ([MapTo]) throws -> Void,
        error errorCallback: ((_ statusCode: Int, _ error: Swift.Error) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?,
        complete completeCallback: (() -> Void)?
    ) {
        request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let items = try response.mapHTML(MapTo.self, atPath: atPath, encoding: .shiftJIS, extra: endpoint.extra)
                    try successCallback(items)
                } catch let error {
                    let errorMessage: String = "There was an error in CycleProvider _request method: \(error)"
                    NSLog("%@", errorMessage)
                    if errorCallback != nil { errorCallback!(response.statusCode, error) }
                }
            case let .failure(error):
                let errorMessage: String = "There was a failure in CycleProvider _request method: \(error)"
                NSLog("%@", errorMessage)
                if failureCallback != nil { failureCallback!(error) }
            }
            if completeCallback != nil { completeCallback!() }
        }
    }
    
    func login(
        username: String,
        password: String,
        success successCallback: @escaping (Login) -> Void,
        error errorCallback: ((_ statusCode: Int, _ error: Swift.Error) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?,
        complete completeCallback: (() -> Void)?
    ) {
        let endpoint = CycleService.login(username: username, password: password)
        request(endpoint) { result in
            switch result {
            case .success(let response):
                do {
                    let items = try response.mapHTML(Login.self, atPath: "input[name='SessionID']:first", encoding: .shiftJIS)
                    guard let login = items.first else {
                        throw NetworkError.authenticationFailed("login failed. couldn't parse login result")
                    }
                    successCallback(login)
                } catch let error {
                    let errorMessage = "There was an error in CycleProvider login method: \(error)"
                    NSLog("%@", errorMessage)
                    if errorCallback != nil { errorCallback!(response.statusCode, error) }
                }
            case let .failure(error):
                let errorMessage = "There was a failure in CycleProvider login method: \(error)"
                NSLog("%@", errorMessage)
                if failureCallback != nil { failureCallback!(error) }
            }
        }
    }
    
    func getCyclePorts(
        username: String,
        sessionID: String,
        for area: CycleServiceArea,
        success successCallback: @escaping ([CyclePort]) -> Void,
        error errorCallback: ((_ statusCode: Int, _ error: Swift.Error) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?,
        complete completeCallback: (() -> Void)?
    ) {
        let endpoint = CycleService.cyclePorts(username: username, sessionID: sessionID, area: area)
        self._request(
            for: endpoint,
            atPath: ".sp_view form",
            success: successCallback,
            error: errorCallback,
            failure: failureCallback,
            complete: completeCallback
        )
    }
    
    func getCycles(
        username: String,
        sessionID: String,
        for cyclePort: CyclePort,
        success successCallback: @escaping ([Cycle]) -> Void,
        error errorCallback: ((_ statusCode: Int, _ error: Swift.Error) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?,
        complete completeCallback: (() -> Void)?
    ) {
        let endpoint = CycleService.cycles(username: username, sessionID: sessionID, cyclePort: cyclePort)
        self._request(
            for: endpoint,
            atPath: ".sp_view form",
            success: successCallback,
            error: errorCallback,
            failure: failureCallback,
            complete: completeCallback
        )
    }
    
    func getRentalStatus(
        username: String,
        sessionID: String,
        success successCallback: @escaping ([RentalStatus]) -> Void,
        error errorCallback: ((_ statusCode: Int, _ error: Swift.Error) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?,
        complete completeCallback: (() -> Void)?
    ) {
        let endpoint = CycleService.status(username: username, sessionID: sessionID)
        self._request(
            for: endpoint,
            atPath: ".main",
            success: successCallback,
            error: errorCallback,
            failure: failureCallback,
            complete: completeCallback
        )
    }
    
    // TODO: in mapHTML support both single item and array return values (Rental instead of [Rental])
    func rent(
        username: String,
        sessionID: String,
        cycle: Cycle,
        success successCallback: @escaping ([Rental]) -> Void,
        error errorCallback: ((_ statusCode: Int, _ error: Swift.Error) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?,
        complete completeCallback: (() -> Void)?
    ) {
        let endpoint = CycleService.rent(username: username, sessionID: sessionID, cycle: cycle)
        self._request(
            for: endpoint,
            atPath: ".main_inner_wide",
            success: successCallback,
            error: errorCallback,
            failure: failureCallback,
            complete: completeCallback
        )
    }
    
    func cancel(
        username: String,
        sessionID: String,
        success successCallback: @escaping () -> Void,
        error errorCallback: ((_ statusCode: Int, _ error: Swift.Error) -> Void)?,
        failure failureCallback: ((MoyaError) -> Void)?,
        complete completeCallback: (() -> Void)?
    ) {
        let endpoint = CycleService.cancelRental(username: username, sessionID: sessionID)
        request(endpoint) { result in
            switch result {
            case .success(_):
                successCallback()
            case let .failure(error):
                let errorMessage = "There was a failure in CycleProvider login method: \(error)"
                NSLog("%@", errorMessage)
                if failureCallback != nil { failureCallback!(error) }
            }
        }
    }
}
