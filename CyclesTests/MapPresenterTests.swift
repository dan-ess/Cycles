//
//  MapPresenterTests.swift
//  CyclesTests
//

import XCTest

@testable import Cycles

class MapPresenterTests: XCTestCase {
    private let port = CyclePort(
        name: "B1-01.十思公園",
        formName: "sp_10047",
        parkingEntID: "TYO",
        parkingID: "10047",
        parkingLat: "35.691058",
        parkingLon: "139.777915",
        cycleCount: "12",
        imageUrl: "../park_img/00010047.jpg"
    )
    
    func testGetCyclePortsForValidAreaShouldSucceed() {
        // given
        let controller = MapViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "okuser", password: "okuser", sessionID: "ok")
        )
        let presenter = MapPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider(),
            rentalCache: RentalCache()
        )
        XCTAssertNil(controller.cyclePorts)
        
        // when
        presenter.getCyclePorts(for: CycleServiceArea.中央区)
        
        // then
        XCTAssertNotNil(controller.cyclePorts)
        
        let cyclePorts = controller.cyclePorts!
        XCTAssertEqual(cyclePorts[0].name, port.name)
        XCTAssertEqual(cyclePorts[0].formName, port.formName)
        XCTAssertEqual(cyclePorts[0].parkingEntID, port.parkingEntID)
        XCTAssertEqual(cyclePorts[0].parkingID, port.parkingID)
        XCTAssertEqual(cyclePorts[0].parkingLat, port.parkingLat)
        XCTAssertEqual(cyclePorts[0].parkingLon, port.parkingLon)
        XCTAssertEqual(cyclePorts[0].cycleCount, port.cycleCount)
        XCTAssertEqual(cyclePorts[0].imageUrl, port.imageUrl)
    }
    
    func testCancelRentalShouldSucceed() {
        // given
        let controller = MapViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "okuser", password: "okuser", sessionID: "ok")
        )
        let presenter = MapPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider(),
            rentalCache: RentalCache()
        )
        XCTAssertNil(controller.cyclePorts)
        
        // when
        presenter.cancelRental()
        
        // then
        XCTAssertTrue(controller.didCancelRentalCalled)
    }
    
    func testRentalStatusShouldReturnReserved() {
        // given
        let controller = MapViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "okuser", password: "okuser", sessionID: "ok")
        )
        let presenter = MapPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider(),
            rentalCache: RentalCache()
        )
        
        // when
        presenter.getRentalStatus()
        
        // then
        XCTAssertTrue(controller.didUpdateRentalStatusCalled)
        let status = controller.rentalStatus!
        XCTAssertEqual(status, RentalStatus.Reserved)
    }
}

class MapViewControllerMock: MapDelegate {
    var didCancelRentalCalled = false
    var didUpdateCyclePortsCalled = false
    var didUpdateRentalStatusCalled = false
    var cyclePorts: [CyclePort]? = nil
    var rentalStatus: RentalStatus? = nil
    
    func didUpdateCyclePorts(cyclePorts: [CyclePort]) {
        self.cyclePorts = cyclePorts
    }
    
    func didCancelRental() {
        didCancelRentalCalled = true
    }
    
    func didUpdateRentalStatus(status: RentalStatus) {
        self.didUpdateRentalStatusCalled = true
        self.rentalStatus = status
    }
}
