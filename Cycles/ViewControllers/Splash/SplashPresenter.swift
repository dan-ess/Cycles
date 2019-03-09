//
//  SplashPresenter.swift
//  Cycles
//

import Moya

protocol LoginDelegate: class {
    func loginDidSucceed()
    func loginDidFail(message: String?)
}

class SplashPresenter {
    private unowned var delegate: LoginDelegate
    private var apiProvider: ApiProvider
    private var userManager: UserManagerProtocol
    
    init(
        delegate: LoginDelegate,
        userManager : UserManagerProtocol,
        apiProvider: ApiProvider
    ) {
        self.delegate = delegate
        self.apiProvider = apiProvider
        self.userManager = userManager
    }
    
    func login() {
        guard var user = userManager.currentUser else {
            self.delegate.loginDidFail(message: nil)
            return
        }

        apiProvider.login(
            username: user.username,
            password: user.password,
            success: { [weak self] (login) in
                guard let strongSelf = self else { return }
                user.sessionID = login.sessionID!
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
