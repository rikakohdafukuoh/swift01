//
//  NumbersAPITests.swift
//  HelloSwiftUITests
//
//  Created by 藤原 on 2023/11/08.
//

import XCTest
@testable import HelloSwiftUI


class PageIndexedNumbersTests: XCTestCase {
    
    let testList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
    
    func testNumbers() throws {
        // レスポンスを定義。
        let response: Response = (
            // 200 OK ステータスコード
            statusCode: .ok,
            
            // ヘッダー設定
            headers: ["Content-Type": "application/json"],
            
            // ペイロード設定
            payload: try JSONSerialization.data(withJSONObject: testList)
        )
        
        switch PageIndexedNumbers.from(response: response) {
        case let .left(error):
            // ここにきてしまったらわかりやすいようにする。
            XCTFail("\(error)")
            
        case let .right(pageIndexedNumbers):
            XCTAssertEqual(pageIndexedNumbers.numbers, testList)
        }
    }
    
    func testNumbersFetch() {
        let expectation = self.expectation(description: "API")
        
        PageIndexedNumbers.fetch(by: 1) { errorOrNumbers in
            switch errorOrNumbers {
            case let .left(error):
                XCTFail("\(error)")
            case let .right(pageIndexedNumbers):
                XCTAssertEqual(pageIndexedNumbers.numbers, self.testList)
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10)
    }
}

