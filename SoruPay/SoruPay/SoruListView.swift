//
//  SoruListView.swift
//  SoruPay
//
//  Created by Berke  on 5.10.2024.
//


// SoruListView.swift

import SwiftUI
import FirebaseFirestore


struct Soru: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var ders: String
    var soruFotoURL: String
    var begeniSayisi: Int
    var createdAt: Timestamp
}

struct SoruListView: View {
    @State private var sorular = [Soru]()
    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            List(sorular.sorted(by: { $0.begeniSayisi > $1.begeniSayisi })) { soru in
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
                            begen(soru: soru)
                        }) {
                            Image(systemName: "hand.thumbsup")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.vertical, 5)
            }
            .navigationBarTitle("Sorular")
        }
        .onAppear {
            fetchSorular()
        }
    }

    func fetchSorular() {
        db.collection("sorular")
            .order(by: "begeniSayisi", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    return
                }

                sorular = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Soru.self)
                } ?? []
            }
    }

    func begen(soru: Soru) {
        guard let id = soru.id else { return }
        let soruRef = db.collection("sorular").document(id)
        soruRef.updateData([
            "begeniSayisi": soru.begeniSayisi + 1
        ]) { error in
            if let error = error {
                print("Beğeni güncelleme hatası: \(error.localizedDescription)")
            }
        }
    }
}

struct SoruListView_Previews: PreviewProvider {
    static var previews: some View {
        SoruListView()
    }
}
