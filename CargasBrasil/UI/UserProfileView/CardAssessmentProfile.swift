//
//  CardAssessmentProfile.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 19/08/24.
//

import SwiftUI

struct CardAssessmentProfile: View {
    var profileImageURL: String?
    var userName: String
    var reviewText: String
    var starRating: Int
    
    var body: some View {
        HStack(alignment: .top) {
            if let profileImageURL = profileImageURL, let url = URL(string: profileImageURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                } placeholder: {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(reviewText)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.bottom, 4)
                
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

#Preview {
    CardAssessmentProfile(
        profileImageURL: "https://example.com/image.jpg",
        userName: "Carlos",
        reviewText: "Excelente profissional, entregou no prazo!",
        starRating: 5
    )
}
