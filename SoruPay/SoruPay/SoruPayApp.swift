//
//  SoruPayApp.swift
//  SoruPay
//
//  Created by Berke  on 1.10.2024.
//

import SwiftUI
import Firebase



@main
struct SoruPayApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SessionStore())
        }
    }
}
