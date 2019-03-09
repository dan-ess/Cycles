//
//  LoginPresenterTests.swift
//  CyclesTests
//

import XCTest

@testable import Cycles

class LoginPresenterTests: XCTestCase {

    func testLoginWithEmptyUsernameShouldReturnErrorMessage(){
        // Given
        let controller = LoginViewControllerMock()
        let loginPresenter = LoginPresenter(
            delegate: controller,
            userManager: UserManagerMock(),
            apiProvider: stubbedProvider()
        )

        // When
        loginPresenter.login(username: "", password: "password1")
        
        // Then
        XCTAssertTrue(controller.loginDidFailCalled)
        XCTAssertEqual(controller.loginDidFailMessage, "Username cannot be empty")
    }

    // also test user was set
    
    func testLoginWithEmptyPasswordShouldReturnErrorMessage(){
        // Given
        let controller = LoginViewControllerMock()
        let loginPresenter = LoginPresenter(
            delegate: controller,
            userManager: UserManagerMock(),
            apiProvider: stubbedProvider()
        )

        // When
        loginPresenter.login(username: "user1", password: "")

        // Then
        XCTAssertTrue(controller.loginDidFailCalled)
        XCTAssertEqual(controller.loginDidFailMessage, "Password cannot be empty")
    }

    func testLoginWithValidParametersShouldSucceed() {
        // Given
        let controller = LoginViewControllerMock()
        let loginPresenter = LoginPresenter(
            delegate: controller,
            userManager: UserManagerMock(),
            apiProvider: stubbedProvider()
        )

        // When
        loginPresenter.login(username: "user1", password: "password1")

        // Then
        XCTAssertTrue(controller.loginDidSucceedCalled)
    }
    
    func testLoginWithValidParametersShouldSetUser() {
        // Given
        let controller = LoginViewControllerMock()
        let userManager = UserManagerMock()
        let loginPresenter = LoginPresenter(
            delegate: controller,
            userManager: userManager,
            apiProvider: stubbedProvider()
        )
        
        // When
        loginPresenter.login(username: "user1", password: "password1")
        
        // Then
        XCTAssertEqual(userManager.currentUser?.username, "user1")
        XCTAssertEqual(userManager.currentUser?.password, "password1")
        XCTAssertEqual(userManager.currentUser?.sessionID, "TYOuserIDsessionID1111")
    }
}

// MARK: - test helper classes

class LoginViewControllerMock: LoginDelegate {
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
