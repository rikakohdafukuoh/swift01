//
//  MainView.swift
//  HelloSwiftUI
//
//  Created by rika.kohda on 2023/09/04.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ZStack {
            if appState.isLogin {
                NumbersView()
            } else {
                SplashView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(AppState())
    }
}
