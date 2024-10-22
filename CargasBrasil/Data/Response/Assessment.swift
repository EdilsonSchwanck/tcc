//
//  Assessment.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 27/08/24.
//

import Foundation

struct Assessment: Identifiable, Hashable, Codable {
    
    var id: String = UUID().uuidString
    let imageURL: String
    let textAssessment: String
    let nota: Int
    let nomeUsuario: String
    let nameUserAssessmet: String

    static func == (lhs: Assessment, rhs: Assessment) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
