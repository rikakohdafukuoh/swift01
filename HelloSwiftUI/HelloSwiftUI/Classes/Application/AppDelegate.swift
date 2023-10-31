//
//  AppDelegate.swift
//  HelloSwiftUI
//
//  Created by jun.kohda on 2023/09/17.
//

import OHHTTPStubs
import OHHTTPStubsSwift
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mock()
        return true
    }
    
    private func mock() {
        stub(condition: isScheme("https") && isHost("mobile.app.hub.com") && isPath("/items")) { request in
            var page = 0
            guard let url = request.url else {
                return HTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: URLError.badServerResponse.rawValue))
            }
            if let value = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { item in
                item.name == "page"
            })?.value, let number = Int(value) {
                page = number - 1
            }
            return HTTPStubsResponse(jsonObject: (0 ..< 30).map({ $0 + 30 * page }), statusCode: 200, headers: ["Content-Type": "application/json"]).responseTime(TimeInterval(1 * Int.random(in: 1..<3)))
        }
    }
}
