//
//  ContentView.swift
//  SoruPay
//
//  Created by Berke  on 1.10.2024.
//

// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        NavigationView {
            if session.currentUser != nil {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionStore())
    }
}
