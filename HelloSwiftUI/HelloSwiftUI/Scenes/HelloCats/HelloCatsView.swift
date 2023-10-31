//
//  ContentView.swift
//  HelloSwiftUI
//
//  Created by rika.kohda on 2023/09/04.
//

import SwiftUI

struct HelloCatsView: View {
    @State var str = "Hello,cats"
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(str)
                .foregroundColor(Color(0xFF00FF, alpha: 1.0))
            Button("猫が増えるボタン") {
                str = "Welcome,cats!"
                print("🐈")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HelloCatsView()
    }
}
