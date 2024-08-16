//
//  ProfileImageView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 14/08/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ProfileImageView: View {
    let imageURL: String?
    @State private var profileImage: UIImage? = nil

    var body: some View {
        if let profileImage = profileImage {
            Image(uiImage: profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
        } else {
            Image("placeholder") // Imagem padrão caso a imagem ainda não tenha sido carregada
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .onAppear {
                    loadImage()
                }
        }
    }

    private func loadImage() {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            } else {
                print("Erro ao carregar imagem da URL: \(error?.localizedDescription ?? "Erro desconhecido")")
            }
        }.resume()
    }
}

#Preview {
    ProfileImageView(imageURL: "https://example.com/image.jpg")
}
