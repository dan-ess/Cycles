//
//  SplashPresenterTests.swift
//  CyclesTests
//

import XCTest

@testable import Cycles

class SplashPresenterTests: XCTestCase {
    
    func testTryLoginWithNoCurrentUserShouldFail() {
        // Given
        let controller = SplashViewControllerMock()
        let userManager = UserManagerMock()
        let splashPresenter = SplashPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider()
        )
        XCTAssertNil(userManager.currentUser)
        
        // When
        splashPresenter.login()
        
        // Then
        XCTAssertEqual(controller.loginDidFailCalled, true)
    }
    
    func testTryLoginWithInvalidCurrentUserShouldFail() {
        // Given
        let controller = SplashViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "baduser", password: "badpass", sessionID: "")
        )
        let splashPresenter = SplashPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider()
        )

        // When
        splashPresenter.login()

        // Then
        XCTAssertTrue(controller.loginDidFailCalled)
    }

    func testTryLoginWithValidCurrentUserShouldSucceed() {
        // Given
        let controller = SplashViewControllerMock()
        let userManager = UserManagerMock(
            user: User(username: "okuser", password: "okuser", sessionID: "ok")
        )
        let splashPresenter = SplashPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider())

        // When
        splashPresenter.login()

        // Then
        XCTAssertTrue(controller.loginDidSucceedCalled)
    }
}

class SplashViewControllerMock: LoginDelegate {
    var loginDidSucceedCalled = false
    var loginDidFailCalled = false
    var loginDidFailMessage: String?
    
    func loginDidFail(message: String?) {
        loginDidFailCalled = true
        loginDidFailMessage = message
    }
    
    func loginDidSucceed() {
        loginDidSucceedCalled = true
    }
}
