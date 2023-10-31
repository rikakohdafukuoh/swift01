//
//  SplashView.swift
//  HelloSwiftUI
//
//  Created by jun.kohda on 2023/11/01.
//

import SwiftUI

struct SplashView: View {
    @State private var animate = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color(0x41C1F7)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1.0 : 0.6)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)

                Text("Splash View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .onAppear() {
            withAnimation {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                appState.changeRootView()
            }
        }
    }
}
