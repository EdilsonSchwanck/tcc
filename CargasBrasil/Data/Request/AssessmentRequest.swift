//
//  AssessmentRequest.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 27/08/24.
//

import Foundation
import SwiftUI

class AssessmentRequest: Encodable {

    var imageCNH: Data?
    var textAssessment: String?
    var nota: Int?
    var nameUser: String?
    let nameUserAssessmet: String?
    
    init(imageCNH: UIImage? = nil, textAssessment: String?, nota: Int?, nameUser: String?, nameUserAssessmet: String) {
        self.textAssessment = textAssessment
        self.nota = nota
        self.nameUser = nameUser
        self.nameUserAssessmet = nameUserAssessmet
        if let image = imageCNH {
            self.imageCNH = image.jpegData(compressionQuality: 0.8) // Converte UIImage para Data
        }
        
        
    }
    
    enum CodingKeys: String, CodingKey {
        case imageCNH
        case textAssessment
        case nota
        case nameUser
        case nameUserAssessmet
    }
}
