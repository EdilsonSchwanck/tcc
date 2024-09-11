//
//  Message.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 14/08/24.
//

import Foundation
import UIKit

struct Message: Identifiable, Equatable {
    let id: String
    let text: String
    let isSentByCurrentUser: Bool
    let timestamp: TimeInterval
    let userName: String
    let userImageURL: String?
    let isCompany: Bool?
    let cpfCnpj: String?
    let plateVheicle: String?
    let typeVheicle: String?
   

    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
