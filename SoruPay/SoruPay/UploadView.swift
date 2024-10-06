//
//  UploadView.swift
//  SoruPay
//
//  Created by Berke  on 5.10.2024.
//

// UploadView.swift

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct UploadView: View {
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var selectedDers = "Matematik"
    @State private var errorMessage = ""
    let dersler = ["Matematik", "Fizik", "Kimya", "Biyoloji"]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Text("Fotoğraf Seç")
                                .foregroundColor(.white)
                        )
                        .cornerRadius(10)
                }

                Button(action: {
                    showImagePicker = true
                }) {
                    Text("Fotoğraf Seç")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(8)
                }

                Picker("Ders", selection: $selectedDers) {
                    ForEach(dersler, id: \.self) { ders in
                        Text(ders)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: {
                    if let image = image {
                        uploadImage(image: image)
                    } else {
                        errorMessage = "Lütfen bir fotoğraf seçin."
                    }
                }) {
                    Text("Soru Paylaş")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .navigationBarTitle("Soru Paylaş", displayMode: .inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
        }
        
    }

    func uploadImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Fotoğraf işlenemedi."
            return
        }

        let storageRef = Storage.storage().reference().child("sorular/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                errorMessage = "Yükleme hatası: \(error.localizedDescription)"
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    errorMessage = "URL alma hatası: \(error.localizedDescription)"
                    return
                }

                if let url = url {
                    saveQuestion(imageURL: url.absoluteString)
                }
            }
        }
    }

    func saveQuestion(imageURL: String) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Kullanıcı oturumu bulunamadı."
            return
        }

        let db = Firestore.firestore()
        db.collection("sorular").addDocument(data: [
            "userId": user.uid,
            "ders": selectedDers,
            "soruFotoURL": imageURL,
            "begeniSayisi": 0,
            "createdAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                errorMessage = "Veritabanına kaydetme hatası: \(error.localizedDescription)"
            } else {
                // Başarılı kaydetme sonrası yapılacaklar
                image = nil
                errorMessage = "Soru başarıyla yüklendi."
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
    }
}

