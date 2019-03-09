//
//  UserManager.swift
//  Cycles
//

import SwiftKeychainWrapper

protocol UserManagerProtocol {
    var currentUser: User? { get set }
    func logout()
}

class UserManager: UserManagerProtocol {
    static let shared = UserManager()
    
    var currentUser: User? {
        get {
            guard
                let username: String = KeychainWrapper.standard.string(forKey: "username"),
                let password: String = KeychainWrapper.standard.string(forKey: "password"),
                let sessionID: String = KeychainWrapper.standard.string(forKey: "sessionID")
            else {
                return nil
            }
            return User(username: username, password: password, sessionID: sessionID)
        }
        
        set {
            if let username = newValue?.username {
                KeychainWrapper.standard.set(username, forKey: "username")
            }
            if let password = newValue?.password {
                KeychainWrapper.standard.set(password, forKey: "password")
            }
            if let sessionID = newValue?.sessionID {
                KeychainWrapper.standard.set(sessionID, forKey: "sessionID")
            }
        }
    }

    func logout() {
        KeychainWrapper.standard.removeObject(forKey: "username")
        KeychainWrapper.standard.removeObject(forKey: "password")
        KeychainWrapper.standard.removeObject(forKey: "sessionID")
    }
}
