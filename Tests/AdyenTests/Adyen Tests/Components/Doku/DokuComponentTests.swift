//
//  DokuComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 1/25/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class DokuComponentTests: XCTestCase {

    lazy var paymentMethod = DokuPaymentMethod(type: "test_type", name: "test_name")
    let payment = Payment(amount: Amount(value: 2, currencyCode: "IDR"), countryCode: "ID")

    func testLocalizationWithCustomTableName() {
        let sut = DokuComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        XCTAssertEqual(sut.firstNameItem?.title, localizedString(.firstName, sut.localizationParameters))
        XCTAssertEqual(sut.firstNameItem?.placeholder, localizedString(.firstName, sut.localizationParameters))
        XCTAssertNil(sut.firstNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.lastNameItem?.title, localizedString(.lastName, sut.localizationParameters))
        XCTAssertEqual(sut.lastNameItem?.placeholder, localizedString(.lastName, sut.localizationParameters))
        XCTAssertNil(sut.lastNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.emailItem?.title, localizedString(.emailItemTitle, sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.placeholder, localizedString(.emailItemPlaceHolder, sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.validationFailureMessage, localizedString(.emailItemInvalid, sut.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(.confirmPurchase, sut.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() {
        let sut = DokuComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        XCTAssertEqual(sut.firstNameItem?.title, localizedString(LocalizationKey(key: "adyen_firstName"), sut.localizationParameters))
        XCTAssertEqual(sut.firstNameItem?.placeholder, localizedString(LocalizationKey(key: "adyen_firstName"), sut.localizationParameters))
        XCTAssertNil(sut.firstNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.lastNameItem?.title, localizedString(LocalizationKey(key: "adyen_lastName"), sut.localizationParameters))
        XCTAssertEqual(sut.lastNameItem?.placeholder, localizedString(LocalizationKey(key: "adyen_lastName"), sut.localizationParameters))
        XCTAssertNil(sut.lastNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.emailItem?.title, localizedString(LocalizationKey(key: "adyen_emailItem_title"), sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.placeholder, localizedString(LocalizationKey(key: "adyen_emailItem_placeHolder"), sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_emailItem_invalid"), sut.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(LocalizationKey(key: "adyen_confirmPurchase"), sut.localizationParameters))
    }

    func testUIConfiguration() {
        var style = FormComponentStyle()

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// background color
        style.backgroundColor = .yellow

        /// Text field
        style.textField.text.color = .brown
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red

        let sut = DokuComponent(paymentMethod: paymentMethod, apiContext: Dummy.context, style: style)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        /// Test firstName field
        self.assertTextInputUI(DokuViewIdentifier.firstName,
                               view: sut.viewController.view,
                               style: style.textField,
                               isFirstField: true)

        /// Test lastName field
        self.assertTextInputUI(DokuViewIdentifier.lastName,
                               view: sut.viewController.view,
                               style: style.textField,
                               isFirstField: false)

        /// Test email field
        self.assertTextInputUI(DokuViewIdentifier.email,
                               view: sut.viewController.view,
                               style: style.textField,
                               isFirstField: false)

        /// Test submit button
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: DokuViewIdentifier.payButton)
        let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.payButtonItem.button.titleLabel")

        XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
        XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
        XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
        XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
        XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))
    }

    private func assertTextInputUI(_ identifier: String,
                                   view: UIView,
                                   style: FormTextItemStyle,
                                   isFirstField: Bool) {

        let textView: FormTextInputItemView? = view.findView(with: identifier)
        let textViewTitleLabel: UILabel? = view.findView(with: "\(identifier).titleLabel")
        let textViewTextField: UITextField? = view.findView(with: "\(identifier).textField")

        XCTAssertEqual(textView?.backgroundColor, .red)
        XCTAssertEqual(textViewTitleLabel?.textColor, isFirstField ? view.tintColor : style.title.color)
        XCTAssertEqual(textViewTitleLabel?.backgroundColor, style.title.backgroundColor)
        XCTAssertEqual(textViewTitleLabel?.textAlignment, style.title.textAlignment)
        XCTAssertEqual(textViewTitleLabel?.font, style.title.font)
        XCTAssertEqual(textViewTextField?.backgroundColor, style.backgroundColor)
        XCTAssertEqual(textViewTextField?.textAlignment, style.text.textAlignment)
        XCTAssertEqual(textViewTextField?.textColor, style.text.color)
        XCTAssertEqual(textViewTextField?.font, style.text.font)
    }

    func testSubmitForm() {
        let sut = DokuComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        sut.payment = payment

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is DokuDetails)
            let data = data.paymentMethod as! DokuDetails
            XCTAssertEqual(data.firstName, "Mohamed")
            XCTAssertEqual(data.lastName, "Smith")
            XCTAssertEqual(data.emailAddress, "mohamed.smith@domain.com")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let submitButton: UIControl? = sut.viewController.view.findView(with: DokuViewIdentifier.payButton)

            let firstNameView: FormTextInputItemView! = sut.viewController.view.findView(with: DokuViewIdentifier.firstName)
            self.populate(textItemView: firstNameView, with: "Mohamed")

            let lastNameView: FormTextInputItemView! = sut.viewController.view.findView(with: DokuViewIdentifier.lastName)
            self.populate(textItemView: lastNameView, with: "Smith")

            let emailView: FormTextInputItemView! = sut.viewController.view.findView(with: DokuViewIdentifier.email)
            self.populate(textItemView: emailView, with: "mohamed.smith@domain.com")

            submitButton?.sendActions(for: .touchUpInside)

            dummyExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testBigTitle() {
        let sut = DokuComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, self.paymentMethod.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testRequiresModalPresentation() {
        let dokuPaymentMethod = DokuPaymentMethod(type: "doku_wallet", name: "Test name")
        let sut = DokuComponent(paymentMethod: dokuPaymentMethod, apiContext: Dummy.context)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testDokuPrefilling() throws {
        // Given
        let prefillSut = DokuComponent(paymentMethod: paymentMethod,
                                       apiContext: Dummy.context,
                                       shopperInformation: shopperInformation)
        UIApplication.shared.keyWindow?.rootViewController = prefillSut.viewController

        wait(for: .seconds(1))

        // Then
        let view: UIView = prefillSut.viewController.view

        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: DokuViewIdentifier.firstName))
        let expectedFirstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let firstName = firstNameView.item.value
        XCTAssertEqual(expectedFirstName, firstName)

        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: DokuViewIdentifier.lastName))
        let expectedLastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let lastName = lastNameView.item.value
        XCTAssertEqual(expectedLastName, lastName)

        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: DokuViewIdentifier.email))
        let expectedEmail = try XCTUnwrap(shopperInformation.emailAddress)
        let email = emailView.item.value
        XCTAssertEqual(expectedEmail, email)
    }

    func testDoku_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        let sut = DokuComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context,
                                shopperInformation: nil)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .seconds(1))

        // Then
        let view: UIView = sut.viewController.view

        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: DokuViewIdentifier.firstName))
        let firstName = firstNameView.item.value
        XCTAssertTrue(firstName.isEmpty)

        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: DokuViewIdentifier.lastName))
        let lastName = lastNameView.item.value
        XCTAssertTrue(lastName.isEmpty)

        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: DokuViewIdentifier.email))
        let email = emailView.item.value
        XCTAssertTrue(email.isEmpty)
    }

    // MARK: - Private

    private enum DokuViewIdentifier {
        static let firstName = "AdyenComponents.DokuComponent.firstNameItem"
        static let lastName = "AdyenComponents.DokuComponent.lastNameItem"
        static let email = "AdyenComponents.DokuComponent.emailItem"
        static let payButton = "AdyenComponents.DokuComponent.payButtonItem.button"
    }

    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             telephoneNumber: "1234567890",
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: deliveryAddress,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
    }
}
