//
//  PhoneFormatter.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 15/09/24.
//

import Foundation
class PhoneFormatter {
    
    func applyMask(_ value: String) -> String {
        let phoneMask = "(##) # ####-####"
        let landlineMask = "(##) # ###-####"
        
        let digits = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        let mask = digits.count > 10 ? phoneMask : landlineMask
        
        var masked = ""
        var index = digits.startIndex
        for ch in mask where index < digits.endIndex {
            if ch == "#" {
                masked.append(digits[index])
                index = digits.index(after: index)
            } else {
                masked.append(ch)
            }
        }
        return masked
    }
    
    func removeMask(_ value: String) -> String {
        return value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}
