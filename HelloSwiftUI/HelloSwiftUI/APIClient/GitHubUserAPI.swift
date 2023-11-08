//
//  GitHubUserAPI.swift
//  HelloSwiftUI
//
//  Created by 藤原 on 2023/11/08.
//

import Foundation

struct GitHubUser: Codable {
    /// GitHub の ID 番号。
    let id: Int
    
    /// GitHub のログイン名。
    let login: String
    
    // （プロパティは他にもあるが今回は省略して実装する）
    static func from(response: Response) -> Either<TransformError, GitHubUser> {
        switch response.statusCode {
        case .ok:
            do {
                // User API は JSON 形式の文字列を返すはずので Data を JSON として
                // 解釈してみる。
                let jsonDecoder = JSONDecoder()
                let user = try jsonDecoder.decode(GitHubUser.self, from: response.payload)
                return .right(user)
            }
            catch {
                // もし、Data が JSON 文字列でなければ、何か間違ったデータを受信してしまったのかもしれない。
                // この場合は、malformedData エラーを返す（エラーの型は左なので .left を使う）。
                return .left(.malformedData(debugInfo: "\(error)"))
            }
        default:
            // エラーの内容がわかりやすいようにステータスコードを入れて返す。
            return .left(.unexpectedStatusCode(debugInfo: "\(response.statusCode)"))
        }
    }
    
    static func fetch (by login: String) async -> Either<Either<ConnectionError, TransformError>, GitHubUser> {
        let urlString = "https://api.github.com/users"
        guard let url = URL(string: urlString)?.appendingPathComponent(login) else {
            return .left(.left(.malformedURL(debugInfo: "\(urlString)/\(login)")))
        }
        
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
            let errorOrUser = GitHubUser.from(response: response)
            
            switch errorOrUser {
            case let .left(error):
                // 変換エラーの場合は、変換エラーを渡す。
                return .left(.right(error))
                
            case let .right(user):
                // 正常に変換できた場合は、GitHubZen オブジェクトを渡す。
                return .right(user)
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
