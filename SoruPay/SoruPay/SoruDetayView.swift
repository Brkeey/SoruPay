//
//  SoruDetayView.swift
//  SoruPay
//
//  Created by Berke  on 6.10.2024.
//

// SoruDetayView.swift

import SwiftUI
import FirebaseFirestore

struct SoruDetayView: View {
    var soru: Soru
    @State private var yorum = ""
    @State private var yorumlar = [Yorum]()
    let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(soru.ders)
                    .font(.largeTitle)
                    .bold()

                AsyncImage(url: URL(string: soru.soruFotoURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }

                Text("Beğeni: \(soru.begeniSayisi)")
                    .font(.headline)

                Divider()

                Text("Yorumlar")
                    .font(.title2)
                    .bold()

                ForEach(yorumlar) { yorum in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(yorum.yorum)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5)
                        Text(yorum.timestamp.dateValue(), style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 5)
                }

                HStack {
                    TextField("Yorum ekle...", text: $yorum)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: ekleYorum) {
                        Text("Gönder")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Soru Detay", displayMode: .inline)
        .onAppear {
            fetchYorumlar()
        }
    }

    func fetchYorumlar() {
        guard let id = soru.id else { return }

        db.collection("sorular").document(id).collection("yorumlar")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Yorumlar sorgulama hatası: \(error.localizedDescription)")
                    return
                }

                yorumlar = snapshot?.documents.compactMap { try? $0.data(as: Yorum.self) } ?? []
            }
    }

    func ekleYorum() {
        guard !yorum.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let id = soru.id else { return }

        let yeniYorum = Yorum(yorum: yorum, timestamp: Timestamp(date: Date()))
        db.collection("sorular").document(id).collection("yorumlar").addDocument(data: [
            "yorum": yeniYorum.yorum,
            "timestamp": yeniYorum.timestamp
        ]) { error in
            if let error = error {
                print("Yorum ekleme hatası: \(error.localizedDescription)")
            } else {
                yorum = ""
            }
        }
    }
}

struct Yorum: Identifiable, Codable {
    @DocumentID var id: String?
    var yorum: String
    var timestamp: Timestamp
}

struct SoruDetayView_Previews: PreviewProvider {
    static var previews: some View {
        SoruDetayView(soru: Soru(userId: "testUser", ders: "Matematik", soruFotoURL: "https://example.com/image.jpg", begeniSayisi: 10, createdAt: Timestamp(date: Date())))
    }
}
