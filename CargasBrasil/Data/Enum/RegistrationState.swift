//
//  RegistrationState.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 08/08/24.
//

import Foundation


enum UserRegistrationState: Equatable {
    case successfullyRegistered
    case failed(error: Error)
    case na

    static func ==(lhs: UserRegistrationState, rhs: UserRegistrationState) -> Bool {
        switch (lhs, rhs) {
        case (.successfullyRegistered, .successfullyRegistered),
             (.na, .na):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
