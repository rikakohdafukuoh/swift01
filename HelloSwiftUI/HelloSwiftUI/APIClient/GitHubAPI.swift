//
//  GitHubAPI.swift
//  HelloSwiftUI
//
//  Created by 藤原 on 2023/11/06.
//

import Foundation

/// GitHub Zen API の結果。
struct GitHubZen {
    /// Zen（禅）なフレーズの文字列。
    let text: String
    
    /// レスポンスからわかりやすいオブジェクトへと変換する関数。
    /// /// ただし、サーバーがエラーを返してきた場合などは変換できないので、
    /// その場合はエラーを返す。つまり、戻り値はエラーがわかりやすいオブジェクトになる。
    /// このような、「どちらか」を意味する Either という型で表現する。
    /// GitHubZen が左でなく右なのは、正しいと Right をかけた慣例。
    static func from(response: Response) -> Either<TransformError, GitHubZen> {
        switch response.statusCode {
        case .ok:
            // HTTP ステータスが OK だったら、ペイロードの中身を確認する。
            // Zen API は UTF-8 で符号化された文字列を返すはずので Data を UTF-8 として
            // 解釈してみる。
            guard let string = String(data: response.payload, encoding: .utf8) else {
                // もし、Data が UTF-8 の文字列でなければ、誤って画像などを受信してしまったのかもしれない。。
                // この場合は、malformedData エラーを返す（エラーの型は左なので .left を使う）。
                return .left(.malformedData(debugInfo: "not UTF-8 string"))
            }
            
            // もし、内容を UTF-8 で符号化された文字列として読み取れたなら、
            // その文字列から GitHubZen を作って返す（エラーではない型は右なので .right を使う）
            return .right(GitHubZen(text: string))
            
        default:
            // もし、HTTP ステータスコードが OK 以外であれば、エラーとして扱う。
            // たとえば、GitHub API を呼び出しすぎたときは 200 OK ではなく 403 Forbidden が
            // 返るのでこちらにくる。
            return .left(.unexpectedStatusCode(
                // エラーの内容がわかりやすいようにステータスコードを入れて返す。
                debugInfo: "\(response.statusCode)")
            )
        }
    }
    
    /// GitHub Zen API を使って、禅なフレーズを取得する関数。
    static func fetch(
        // コールバック経由で、接続エラーか変換エラーか GitHubZen のいずれかを受け取れるようにする。
        _ block: @escaping (Either<Either<ConnectionError, TransformError>, GitHubZen>) -> Void

        // コールバックの引数の型が少しわかりづらいが、次の3パターンになる。
        //
        // - 接続エラーの場合     → .left(.left(ConnectionEither))
        // - 変換エラーの場合     → .left(.right(TransformError))
        // - 正常に取得できた場合 → .right(GitHubZen)
    ) {
        // URL が生成できない場合は不正な URL エラーを返す
        let urlString = "https://api.github.com/zen"
        guard let url = URL(string: urlString) else {
            block(.left(.left(.malformedURL(debugInfo: urlString))))
            return
        }

        // GitHub Zen API は何も入力パラメータがないので入力は固定値になる。
        let input: Input = (
            url: url,
            queries: [],
            headers: [:],
            methodAndPayload: .get
        )

        // GitHub Zen API を呼び出す。
        WebAPI.call(with: input) { output in
            switch output {
            case let .noResponse(connectionError):
                // 接続エラーの場合は、接続エラーを渡す。
                block(.left(.left(connectionError)))

            case let .hasResponse(response):
                // レスポンスがわかりやすくなるように GitHubZen へと変換する。
                let errorOrZen = GitHubZen.from(response: response)

                switch errorOrZen {
                case let .left(error):
                    // 変換エラーの場合は、変換エラーを渡す。
                    block(.left(.right(error)))

                case let .right(zen):
                    // 正常に変換できた場合は、GitHubZen オブジェクトを渡す。
                    block(.right(zen))
                }
            }
        }
    }
    
    /// GitHub Zen API の変換で起きうるエラーの一覧。
    enum TransformError {
        /// HTTP ステータスコードが OK 以外だった場合のエラー。
        case unexpectedStatusCode(debugInfo: String)
        
        /// ペイロードが壊れた文字列だった場合のエラー。
        case malformedData(debugInfo: String)
    }
}


