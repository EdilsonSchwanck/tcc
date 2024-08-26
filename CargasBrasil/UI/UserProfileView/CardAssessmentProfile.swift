//
//  CardAssessmentProfile.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 19/08/24.
//

import SwiftUI

struct CardAssessmentProfile: View {
    var profileImage: Image
    var reviewText: String
    var starRating: Int
    
    var body: some View {
        HStack(alignment: .top) {
            profileImage
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 4)
            
            VStack(alignment: .leading) {
                Text(reviewText)
                    .font(.body)
                    .lineLimit(2)
                    .padding(.bottom, 2)
                
                HStack {
                    ForEach(0..<starRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    ForEach(0..<(5 - starRating), id: \.self) { _ in
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .frame(width: 350) // Limita a largura do card
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}


#Preview {
    CardAssessmentProfile(
        profileImage: Image(systemName: "person.fill"),
        reviewText: "Excelente profissional, entregou no prazo!",
        starRating: 5
    )
}
