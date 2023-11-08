//
//  GitHubAPITests.swift
//  HelloSwiftUITests
//
//  Created by 藤原 on 2023/11/08.
//

import XCTest
@testable import HelloSwiftUI


class GitHubAPITests: XCTestCase {
    func testZenFetch() async {
        // GitHub Zen API には入力パラメータがないので、関数呼び出し時には
        // 引数は指定しなくて済むようにしたい
        let errorOrZen = await GitHubZen.fetch()
        // エラーかレスポンスがきたら下記を実行する
        // できれば、結果はすでに変換済みの GitHubZen オブジェクトを受け取りたい。
        
        switch errorOrZen {
        case let .left(error):
            // エラーがきたらわかりやすいようにする。
            XCTFail("\(error)")
            
        case let .right(zen):
            // 結果をきちんと受け取れたことを確認する。
            XCTAssertNotNil(zen)
        }
    }
    
    
    // API を二度呼ぶ方もかなり可読性が上がっている。
    func testZenFetchTwice() async {
        let errorOrZenOnce = await GitHubZen.fetch()
        switch errorOrZenOnce {
        case let .left(error):
            XCTFail("\(error)")
            
        case .right(_):
            let errorOrZenTwice = await GitHubZen.fetch()
            switch errorOrZenTwice {
            case let .left(error):
                XCTFail("\(error)")
                
            case let .right(zen):
                XCTAssertNotNil(zen)
            }
        }
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
    
    func testUserFetch() async {
        
        let errorOrUser = await GitHubUser.fetch(by: "mutt5")
        switch errorOrUser {
        case let .left(error):
            XCTFail("\(error)")
        case let .right(user):
            XCTAssertEqual(user.id, 69248950)
            XCTAssertEqual(user.login, "mutt5")
        }
    }
    
}
