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
            SoruListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Sorular")
                }

            UploadView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Soru Paylaş")
                }

            LibraryView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Kütüphanem")
                }

            TopSorularView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Günlük Top 5")
                }

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
