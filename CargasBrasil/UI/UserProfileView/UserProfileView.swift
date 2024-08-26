//
//  UserProfileView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 19/08/24.
//

import SwiftUI

struct UserProfileView: View {
    let reviews = [
        ("Excelente profissional, entregou no prazo!", 5),
        ("Muito atencioso, recomendo!", 4),
        ("Bom serviço, mas pode melhorar.", 3),
        ("Não recomendo, houve atrasos.", 2)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Foto do usuário, nome e veículo
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nome do Usuário")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Veículo: Caminhão XYZ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        ForEach(0..<4, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.horizontal)
            
            // Avaliações do usuário
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<reviews.count, id: \.self) { index in
                        CardAssessmentProfile(
                            profileImage: Image(systemName: "person.fill"),
                            reviewText: reviews[index].0,
                            starRating: reviews[index].1
                        )
                    }
                }
                .padding()
            }
        }
        .padding(.top, 60)
        Spacer()
    }
}

#Preview {
    UserProfileView()
}
