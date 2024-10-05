//
//  LibraryView.swift
//  SoruPay
//
//  Created by Berke  on 5.10.2024.
//

// LibraryView.swift

import SwiftUI
import FirebaseFirestore


struct LibraryView: View {
    @EnvironmentObject var session: SessionStore
    @State private var kutuphaneSorular = [Soru]()
    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            List(kutuphaneSorular) { soru in
                VStack(alignment: .leading, spacing: 10) {
                    Text(soru.ders)
                        .font(.headline)

                    AsyncImage(url: URL(string: soru.soruFotoURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }

                    HStack {
                        Text("Beğeni: \(soru.begeniSayisi)")
                        Spacer()
                        Button(action: {
                            scheduleWeeklyNotification(for: soru)
                        }) {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.vertical, 5)
            }
            .navigationBarTitle("Kütüphanem")
        }
        .onAppear {
            fetchKutuphaneSorular()
        }
    }

    func fetchKutuphaneSorular() {
        guard let user = session.currentUser else { return }

        db.collection("kullanicilar")
            .document(user.uid)
            .collection("kutuphane")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Kütüphane sorgulama hatası: \(error.localizedDescription)")
                    return
                }

                let soruIds = snapshot?.documents.compactMap { $0.data()["soruId"] as? String } ?? []

                if soruIds.isEmpty {
                    kutuphaneSorular = []
                    return
                }

                db.collection("sorular")
                    .whereField(FieldPath.documentID(), in: soruIds)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Sorular sorgulama hatası: \(error.localizedDescription)")
                            return
                        }

                        kutuphaneSorular = snapshot?.documents.compactMap { try? $0.data(as: Soru.self) } ?? []
                    }
            }
    }

    func scheduleWeeklyNotification(for soru: Soru) {
        // Bildirimleri planlama fonksiyonu
        NotificationsManager.shared.scheduleWeeklyNotification(for: soru)
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView().environmentObject(SessionStore())
    }
}
