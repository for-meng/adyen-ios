//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class ThrottlerTests: XCTestCase {

    func test() {
        let sut = Throttler(minimumDelay: 1)
        
        let xctExpectation = expectation(description: "wait for last block execution")
        
        let triesCount = 25

        var counter: Int = 0
        
        (0..<triesCount).forEach { index in
            sut.throttle {
                
                counter += 1
                
                if index == triesCount - 1 {
                    xctExpectation.fulfill()
                }
            }
            
            wait(for: .milliseconds(100))
        }
        
        waitForExpectations(timeout: 100, handler: nil)
        
        XCTAssertEqual(counter, 1)
    }

}
