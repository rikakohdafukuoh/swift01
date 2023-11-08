//
//  NumbersAPI.swift
//  HelloSwiftUI
//
//  Created by 藤原 on 2023/11/08.
//

import Foundation

struct PageIndexedNumbers: Codable {
    
    /// page番号に対応する数値の配列
    let numbers: [Int]
    
    static func from(response: Response) -> Either<TransformError, PageIndexedNumbers> {
        switch response.statusCode {
        case .ok:
            do {
                let jsonDecoder = JSONDecoder()
                let fetchedNumbers = try jsonDecoder.decode([Int].self, from: response.payload)
                return .right(PageIndexedNumbers(numbers: fetchedNumbers))
            }
            
            catch {
                return .left(.malformedData(debugInfo: "\(error)"))
            }
        default:
            // エラーの内容がわかりやすいようにステータスコードを入れて返す。
            return .left(.unexpectedStatusCode(debugInfo: "\(response.statusCode)"))
        }
    }
    
    static func fetch(by page: Int) async -> Either<Either<ConnectionError, TransformError>, PageIndexedNumbers> {
        let urlString = "https://mobile.app.hub.com/items"
        guard let url = URL(string: urlString)?.appending(queryItems: [URLQueryItem(name: "page", value: String(page))]) else {
            return .left(.left(.malformedURL(debugInfo: "\(urlString)/?page=\(page)")))
        }
        print("url: \(url)")
        
        let input: Input = (
            url: url,
            queries: [],
            headers: [:],
            methodAndPayload: .get
        )
        
        let output = await WebAPI.call(with: input)
        switch output {
        case let .noResponse(connectionError):
            return .left(.left(connectionError))
            
        case let .hasResponse(response):
            let errorOrNumbers = PageIndexedNumbers.from(response: response)
            
            switch errorOrNumbers {
            case let .left(error):
                // 変換エラーの場合は、変換エラーを渡す。
                return .left(.right(error))
                
            case let .right(numbers):
                // 正常に変換できた場合は、PageIndexedNumbers オブジェクトを渡す。
                return .right(numbers)
            }
        }
    }
    
    /// GitHub User API の変換で起きうるエラーの一覧。
    enum TransformError {
        /// ペイロードが壊れた JSON だった場合のエラー。
        case malformedData(debugInfo: String)
        
        /// HTTP ステータスコードが OK 以外だった場合のエラー。
        case unexpectedStatusCode(debugInfo: String)
    }
}
