//
//  GitHubAPITests.swift
//  HelloSwiftUITests
//
//  Created by 藤原 on 2023/11/08.
//

import XCTest
@testable import HelloSwiftUI


class GitHubAPITests: XCTestCase {
    func testZenFetch() {
            let expectation = self.expectation(description: "API")

            // GitHub Zen API には入力パラメータがないので、関数呼び出し時には
            // 引数は指定しなくて済むようにしたい。また、API 呼び出しは非同期なので、
            // コールバックをとるはず（注: GitHubZen.fetch はあとで定義する）。
            GitHubZen.fetch { errorOrZen in
                // エラーかレスポンスがきたらコールバックが実行されて欲しい。
                // できれば、結果はすでに変換済みの GitHubZen オブジェクトを受け取りたい。

                switch errorOrZen {
                case let .left(error):
                    // エラーがきたらわかりやすいようにする。
                    XCTFail("\(error)")

                case let .right(zen):
                    // 結果をきちんと受け取れたことを確認する。
                    XCTAssertNotNil(zen)
                }

                expectation.fulfill()
            }

            self.waitForExpectations(timeout: 10)
        }


        // API を二度呼ぶ方もかなり可読性が上がっている。
        func testZenFetchTwice() {
            let expectation = self.expectation(description: "API")

            GitHubZen.fetch { errorOrZen in
                switch errorOrZen {
                case let .left(error):
                    XCTFail("\(error)")

                case .right(_):
                    GitHubZen.fetch { errorOrZen in
                        switch errorOrZen {
                        case let .left(error):
                            XCTFail("\(error)")

                        case let .right(zen):
                            XCTAssertNotNil(zen)
                            expectation.fulfill()
                        }
                    }
                }
            }

            self.waitForExpectations(timeout: 10)
        }
    
    func testUser() throws {
        // レスポンスを定義。
        let response: Response = (
            // 200 OK が必要。
            statusCode: .ok,

            // 必要なヘッダーは特にない。
            headers: [:],

            // API レスポンスを GitHubUser へ変換できるか試すだけなので、
            // 適当な ID とログイン名を指定。
            payload: try JSONSerialization.data(withJSONObject: [
                "id": 1,
                "login": "octocat"
            ])
        )

        switch GitHubUser.from(response: response) {
        case let .left(error):
            // ここにきてしまったらわかりやすいようにする。
            XCTFail("\(error)")

        case let .right(user):
            // ID とログイン名が正しく変換できたことを確認する。
            XCTAssertEqual(user.id, 1)
            XCTAssertEqual(user.login, "octocat")
        }
    }
    
    func testUserFetch() {
        let expectation = self.expectation(description: "API")
        
        GitHubUser.fetch(by: "mutt5") { errorOrUser in
            switch errorOrUser {
            case let .left(error):
                XCTFail("\(error)")
            case let .right(user):
                XCTAssertEqual(user.id, 69248950)
                XCTAssertEqual(user.login, "mutt5")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10)
    }
}

