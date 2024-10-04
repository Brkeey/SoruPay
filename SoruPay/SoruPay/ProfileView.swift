//
//  ProfileView.swift
//  SoruPay
//
//  Created by Berke  on 4.10.2024.
//

// ProfileView.swift

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack(spacing: 20) {
            if let user = session.currentUser {
                Text("Hoşgeldiniz, \(user.email ?? "Kullanıcı")")
                    .font(.title)
                    .padding()

                Button(action: {
                    session.signOut()
                }) {
                    Text("Çıkış Yap")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            } else {
                Text("Giriş Yapılmamış")
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("Profil", displayMode: .inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(SessionStore())
    }
}
