//
//  ImageUserRequest.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 13/08/24.
//

import UIKit

class ImageUserRequest: Encodable {

    var imageCNH: Data?
    
    init(imageCNH: UIImage? = nil) {
        if let image = imageCNH {
            self.imageCNH = image.jpegData(compressionQuality: 0.8) // Converte UIImage para Data
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case imageCNH
    }
}
