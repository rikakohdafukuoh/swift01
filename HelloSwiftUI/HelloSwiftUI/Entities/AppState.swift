//
//  AppState.swift
//  HelloSwiftUI
//
//  Created by jun.kohda on 2023/11/01.
//

import Foundation

class AppState: ObservableObject {
    
    @Published var isLogin = false
    
    func changeRootView() {
        self.isLogin.toggle()
    }
}
