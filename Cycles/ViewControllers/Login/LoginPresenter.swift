//
//  LoginPresenter.swift
//  Cycles
//

import Moya

class LoginPresenter {
    private var apiProvider: MoyaProvider<CycleService>
    private var userManager: UserManagerProtocol
    private unowned var delegate: LoginDelegate
    
    init(
        delegate: LoginDelegate,
        userManager: UserManagerProtocol,
        apiProvider: MoyaProvider<CycleService>
    ) {
        self.delegate = delegate
        self.userManager = userManager
        self.apiProvider = apiProvider
    }
    
    func login(username: String, password: String) {
        if username.isEmpty {
            self.delegate.loginDidFail(message: "Username cannot be empty")
            return
        }
        
        if password.isEmpty {
            self.delegate.loginDidFail(message: "Password cannot be empty")
            return
        }
        
        apiProvider.login(
            username: username,
            password: password,
            success: { [weak self] (login) in
                guard let strongSelf = self else { return }
                let user = User(username: username, password: password, sessionID: login.sessionID!)
                strongSelf.userManager.currentUser = user
                strongSelf.delegate.loginDidSucceed()},
            error: { [weak self] (errorCode, error) in
                guard let strongSelf = self else { return }
                strongSelf.delegate.loginDidFail(message: nil)},
            failure: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.delegate.loginDidFail(message: nil)},
            complete: nil
        )
    }
}
