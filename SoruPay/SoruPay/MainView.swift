//
//  MainView.swift
//  SoruPay
//
//  Created by Berke  on 3.10.2024.
//


// MainView.swift

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        TabView {

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profil")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(SessionStore())
    }
}

