//
//  CyclePortPresenterTests.swift
//  CyclesTests
//

import XCTest

@testable import Cycles

private let port = CyclePort(
    name: "B1-01.XXXXXXXX",
    formName: "sp_10047",
    parkingEntID: "TYO",
    parkingID: "10047",
    parkingLat: "35.691058",
    parkingLon: "139.777915",
    cycleCount: "12",
    imageUrl: "../park_img/00010047.jpg"
)

private let cycle = Cycle(
    displayName: "CYD0202",
    cycleEntID: "TYO",
    cycleID: "617",
    centerLat: "35.675702",
    centerLon: "139.785229",
    cycLat: "35.675955",
    cycLon: "139.784585",
    attachID: "10582",
    cycleTypeNo: "4",
    cyclePort: port
)

class CyclePortPresenterTests: XCTestCase {
    func testGetCyclesForValidPortSucceeds() {
        // given
        let controller = CyclePortViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "okuser", password: "okuser", sessionID: "ok")
        )
        let presenter = CyclePortPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider()
        )
        
        // when
        presenter.getCycles(for: port)
        
        // then
        XCTAssertTrue(controller.didUpdateCycles)
    }
    
    func testGetCyclesForValidPortReturnsCycles() {
        // given
        let controller = CyclePortViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "okuser", password: "okuser", sessionID: "ok")
        )
        let presenter = CyclePortPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider()
        )
        
        // when
        presenter.getCycles(for: port)
        
        // then
        let cycles = controller.cycles!
        // check count
        XCTAssertEqual(cycles.count , 3)
        
        // check cycle values
        XCTAssertEqual(cycles[0].displayName, cycle.displayName)
        XCTAssertEqual(cycles[0].cycleEntID, cycle.cycleEntID)
        XCTAssertEqual(cycles[0].cycleID, cycle.cycleID)
        XCTAssertEqual(cycles[0].centerLat, cycle.centerLat)
        XCTAssertEqual(cycles[0].centerLon, cycle.centerLon)
        XCTAssertEqual(cycles[0].cycLat, cycle.cycLat)
        XCTAssertEqual(cycles[0].cycLon, cycle.cycLon)
        XCTAssertEqual(cycles[0].attachID, cycle.attachID)
        XCTAssertEqual(cycles[0].cycleTypeNo, cycle.cycleTypeNo)
    }
    
    func testRentForValidCycleSucceeds() {
        // given
        let controller = CyclePortViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "okuser", password: "okuser", sessionID: "ok")
        )
        let presenter = CyclePortPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider()
        )
        
        // when
        presenter.rent(cycle: cycle)
        
        // then
        XCTAssertTrue(controller.didCompleteRental)
        XCTAssertEqual(controller.rental?.pin, "9834")
    }
}

class CyclePortViewControllerMock: CyclePortDelegate {
    var didCompleteRental = false
    var didUpdateCycles = false
    var rental: Rental? = nil
    var cycles: [Cycle]? = nil
    
    func didCompleteRental(rental: Rental) {
        didCompleteRental = true
        self.rental = rental
    }
    
    func didUpdateCycles(cycles: [Cycle]) {
        didUpdateCycles = true
        self.cycles = cycles
    }
}
