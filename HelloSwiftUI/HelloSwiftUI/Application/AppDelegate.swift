//
//  AppDelegate.swift
//  HelloSwiftUI
//
//  Created by jun.kohda on 2023/11/01.
//

import OHHTTPStubs
import OHHTTPStubsSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        mock()
        // Override point for customization after application launch.
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
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
