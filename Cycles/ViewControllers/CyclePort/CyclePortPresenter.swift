//
//  CyclePortPresenter.swift
//  Cycles
//

import Foundation

import Moya

protocol CyclePortDelegate: class {
    func didCompleteRental(rental: Rental)
    func didUpdateCycles(cycles: [Cycle])
}

class CyclePortPresenter {
    private unowned var delegate: CyclePortDelegate
    private var apiProvider: ApiProvider
    private var userManager: UserManagerProtocol
    
    init(
        delegate: CyclePortDelegate,
        userManager: UserManagerProtocol,
        apiProvider: ApiProvider
    ) {
        self.delegate = delegate
        self.apiProvider = apiProvider
        self.userManager = userManager
    }
    
    func getCycles(for cyclePort: CyclePort) {
        if let user = userManager.currentUser {
            apiProvider.getCycles(
                username: user.username,
                sessionID: user.sessionID,
                for: cyclePort,
                success: { [weak self] cycles in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate.didUpdateCycles(cycles: cycles)
                },
                error: { code, error in print("error!") },
                failure: { error in print ("failure!") },
                complete: {}
            )
        }
    }
    
    func rent(cycle: Cycle) {
        
        if let user = userManager.currentUser {
            apiProvider.rent(
                username: user.username,
                sessionID: user.sessionID,
                cycle: cycle,
                success: { [weak self] rentals in
                    guard let strongSelf = self else { return }
                    guard let rental = rentals.first else {
                        print("failure parsing rental!")
                        return
                    }
                    strongSelf.delegate.didCompleteRental(rental: rental)
                },
                error: { code, error in print("error!") },
                failure: { error in print ("failure!") },
                complete: {}
            )
        }
    }
}
