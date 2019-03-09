//
//  Helpers.swift
//  CyclesTests
//

import Foundation

import Moya

@testable import Cycles

func stubbedProvider() -> ApiProvider {
    return MoyaProvider<CycleService>(stubClosure: MoyaProvider.immediatelyStub)
}

class UserManagerMock: UserManagerProtocol {
    var _user: User?
    
    var currentUser: User? {
        get {
            return _user
        }
        set {
            _user = newValue
        }
    }
    
    init(user: User? = nil) {
        self._user = user
    }
    
    func logout() {}
}
