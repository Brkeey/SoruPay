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
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all) // Arka planı sade beyaz yapıyoruz

                VStack(spacing: 25) {
                    Text("Soru Paylaş")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 250)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo.on.rectangle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)

                                    Text("Fotoğraf Seç")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }

                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Fotoğraf Seç")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }

                    Picker("Ders Seçin", selection: $selectedDers) {
                        ForEach(dersler, id: \.self) { ders in
                            Text(ders)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }

                    Button(action: {
                        if let image = image {
                            uploadImage(image: image)
                        } else {
                            errorMessage = "Lütfen bir fotoğraf seçin."
                        }
                    }) {
                        Text("Soru Paylaş")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 20)

                    Spacer()
                }
                .padding()
                .navigationBarHidden(true)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $image)
                }
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

