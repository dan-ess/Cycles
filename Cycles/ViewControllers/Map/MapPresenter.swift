//
//  MapPresenter.swift
//  Cycles
//

import Moya

protocol MapDelegate: class {
    func didUpdateCyclePorts(cyclePorts: [CyclePort])
    func didCancelRental()
}

class MapPresenter {
    private unowned var delegate: MapDelegate
    private var apiProvider: ApiProvider
    private var userManager: UserManagerProtocol
    private var rentalCache: RentalCache
    
    init(
        delegate: MapDelegate,
        userManager: UserManagerProtocol,
        apiProvider: ApiProvider,
        rentalCache: RentalCache
    ) {
        self.delegate = delegate
        self.userManager = userManager
        self.apiProvider = apiProvider
        self.rentalCache = rentalCache
    }
    
    func getCyclePorts(for area: CycleServiceArea) {
        if let user = userManager.currentUser {
            apiProvider.getCyclePorts(
                username: user.username,
                sessionID: user.sessionID,
                for: area,
                success: { [weak self] items in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate.didUpdateCyclePorts(cyclePorts: items)
                },
                error: { code, error in print("error!") },
                failure: { error in print("failure!") },
                complete: {}
            )
        }
    }
    
    func cancelRental() {
        if let user = userManager.currentUser {
            apiProvider.cancel(
                username: user.username,
                sessionID: user.sessionID,
                success: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate.didCancelRental()
                    strongSelf.rentalCache.clear(forKey: Caches.rental.rawValue)
                    
                },
                error: { [weak self] (errorCode, error) in
                    // TODO: handle error
                    //guard let strongSelf = self else { return }
                },
                failure: { [weak self] error in
                    // TODO: handle failure
                    //guard let strongSelf = self else { return }
                },
                complete: { [weak self] in
                    // TODO: handle complete
                    //guard let strongSelf = self else { return }
                }
            )
        }
    }
}
