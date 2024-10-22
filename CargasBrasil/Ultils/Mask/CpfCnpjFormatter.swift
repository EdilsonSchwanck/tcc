//
//  CpfCnpjFormatter.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 15/09/24.
//

import Foundation

class CpfCnpjFormatter {
    
    // Aplica máscara de CPF ou CNPJ
    func applyMask(_ value: String, isCompany: Bool) -> String {
        let cpfMask = "###.###.###-##"
        let cnpjMask = "##.###.###/####-##"
        
        let mask = isCompany ? cnpjMask : cpfMask
        
        // Remove qualquer caractere que não seja número
        let digits = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
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
    
    // Remove a máscara para enviar ao banco de dados
    func removeMask(_ value: String) -> String {
        // Remove os pontos, traços e barras
        return value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}
