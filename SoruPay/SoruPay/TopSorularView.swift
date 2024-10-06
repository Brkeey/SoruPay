//
//  TopSorularView.swift
//  SoruPay
//
//  Created by Berke  on 5.10.2024.
//

// TopSorularView.swift

import SwiftUI
import FirebaseFirestore


struct TopSorularView: View {
    @State private var topSorular = [Soru]()
    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            List(topSorular) { soru in
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

                    Text("Beğeni: \(soru.begeniSayisi)")
                        .font(.subheadline)
                }
                .padding(.vertical, 5)
            }
            .navigationBarTitle("Günün Top 5 Sorusu")
        }
        .onAppear {
            fetchDailyTopSorular()
        }
    }

    func fetchDailyTopSorular() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        db.collection("sorular")
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("createdAt", isLessThan: Timestamp(date: endOfDay))
            .order(by: "begeniSayisi", descending: true)
            .limit(to: 5)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Top sorular sorgulama hatası: \(error.localizedDescription)")
                    return
                }

                topSorular = snapshot?.documents.compactMap { try? $0.data(as: Soru.self) } ?? []
            }
    }
}

struct TopSorularView_Previews: PreviewProvider {
    static var previews: some View {
        TopSorularView()
    }
}
