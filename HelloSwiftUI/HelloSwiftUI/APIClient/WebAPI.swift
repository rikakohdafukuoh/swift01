//
//  WebAPI.swift
//  HelloSwiftUI
//
//  Created by 藤原 on 2023/11/06.
//

import Foundation


/// API への入力は Request そのもの。
typealias Input = Request


/// Request は以下の要素から構成される:
typealias Request = (
    /// リクエストの向き先の URL。
    url: URL,
    
    /// クエリ文字列。クエリは URLQueryItem という標準のクラスを使っている。
    queries: [URLQueryItem],
    
    /// HTTP ヘッダー。ヘッダー名と値の辞書になっている。
    headers: [String: String],
    
    /// HTTP メソッドとペイロードの組み合わせ。
    /// GET にはペイロードがなく、PUT や POST にはペイロードがあることを
    /// 表現するために、後述する enum を使っている。
    methodAndPayload: HTTPMethodAndPayload
)


/// HTTP メソッドとペイロードの組み合わせ。
enum HTTPMethodAndPayload {
    /// GET メソッドの定義。
    case get
    
    /// POST メソッドの定義（必要になるまでは省略）。
    // case post(payload: Data?)
    
    /// メソッドの文字列表現。
    var method: String {
        switch self {
        case .get:
            return "GET"
        }
    }
    
    /// ペイロード。ペイロードがないメソッドの場合は nil。
    var body: Data? {
        switch self {
        case .get:
            // GET はペイロードを取れないので nil。
            return nil
        }
    }
}

enum WebAPI {
    // コールバックつきの call 関数を用意する。
    // コールバック関数に与えられる引数は、Output 型（レスポンスか通信エラーのどちらか）。
    static func call(with input: Input, _ block: @escaping (Output) -> Void) {
        
        // 実際にサーバーと通信するコードはまだはっきりしていないので、
        // Timer を使って非同期なコード実行だけを再現する。
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            
            // 仮のレスポンスをでっちあげる。
            let response: Response = (
                statusCode: .ok,
                headers: [:],
                payload: "this is a response text".data(using: .utf8)! // 👈 最終的にこのコードは消えるので force unwrap しています
            )
            
            // 仮のレスポンスでコールバックを呼び出す。
            block(.hasResponse(response))
        }
    }
    
    static func call(with input: Input) {
        self.call(with: input) { _ in
            // NOTE: コールバックでは何もしない
        }
    }
}

/// API の出力にをあらわす enum。
/// API の出力でありえるのは、
enum Output {
    /// レスポンスがある場合か、
    case hasResponse(Response)
    
    /// 通信エラーでレスポンスがない場合。
    case noResponse(ConnectionError)
}



/// 通信エラー。
enum ConnectionError {
    /// データまたはレスポンスが存在しない場合のエラー。
    case noDataOrNoResponse(debugInfo: String)
}



/// API のレスポンス。構成要素は、以下の3つ。
typealias Response = (
    /// レスポンスの意味をあらわすステータスコード。
    statusCode: HTTPStatus,
    
    /// HTTP ヘッダー。
    headers: [String: String],
    
    /// レスポンスの本文。
    payload: Data
)


/// HTTPステータスコードを読みやすくする型。
enum HTTPStatus {
    /// OK の場合。HTTP ステータスコードでは 200 にあたる。
    case ok
    
    /// OK ではなかった場合の例。
    /// notFound の HTTP ステータスコードは 404 で、
    /// リクエストで要求された項目が存在しなかったことを意味する。
    case notFound
    
    /// 他にもステータスコードはあるが、全部定義するのは面倒なので、
    /// 必要ペースで定義できるようにする。
    case unsupported(code: Int)
    
    /// HTTP ステータスコードから HTTPステータス型を作る関数。
    static func from(code: Int) -> HTTPStatus {
        switch code {
        case 200:
            // 200 は OK の意味。
            return .ok
        case 404:
            // 404 は notFound の意味。
            return .notFound
        default:
            // それ以外はまだ対応しない。
            return .unsupported(code: code)
        }
    }
}

/// 型 A か型 B のどちらかのオブジェクトを表す型。
/// たとえば、Either<String, Int> は文字列か整数のどちらかを意味する。
/// なお、慣例的にどちらの型かを左右で表現することが多い。
enum Either<Left, Right> {
    /// Eigher<A, B> の A の方の型。
    case left(Left)
    
    /// Eigher<A, B> の B の方の型。
    case right(Right)
    
    
    /// もし、左側の型ならその値を、右側の型なら nil を返す。
    var left: Left? {
        switch self {
        case let .left(x):
            return x
            
        case .right:
            return nil
        }
    }
    
    /// もし、右側の型ならその値を、左側の型なら nil を返す。
    var right: Right? {
        switch self {
        case .left:
            return nil
            
        case let .right(x):
            return x
        }
    }
}
