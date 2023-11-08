//
//  GitHubUserAPITests.swift
//  HelloSwiftUITests
//
//  Created by 藤原 on 2023/11/08.
//

import XCTest
@testable import StartSmallForAPI


class GitHubAPITests: XCTestCase {
    func testZenFetch() {
        // ...(省略)...
    }


    func testZenFetchTwice() {
        // ...(省略)...
    }


    // レスポンスを GitHubUser へ変換できることを確かめる動作確認コード。
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
}

