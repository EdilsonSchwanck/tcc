//
//  NewJobRequest.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 12/08/24.
//

import Foundation

class NewJobRequest: Encodable {
    var latitudeColeta: Double
    var longitudeColeta: Double
    var latitudeEntrega: Double
    var longitudeEntrega: Double
    var destinoColeta: String
    var destinoEntrega: String
    var telefone: String
    var tipodeCarga: String
    var tipoDeCaminhao: String
    var valor: String
   
    init(latitudeColeta: Double, longitudeColeta: Double, latitudeEntrega: Double, longitudeEntrega: Double, destinoColeta: String, destinoEntrega: String, telefone: String, tipodeCarga: String, tipoDeCaminhao: String, valor: String) {
        self.latitudeColeta = latitudeColeta
        self.longitudeColeta = longitudeColeta
        self.latitudeEntrega = latitudeEntrega
        self.longitudeEntrega = longitudeEntrega
        self.destinoColeta = destinoColeta
        self.destinoEntrega = destinoEntrega
        self.telefone = telefone
        self.tipodeCarga = tipodeCarga
        self.tipoDeCaminhao = tipoDeCaminhao
        self.valor = valor
    }
    
    enum CodingKeys: String, CodingKey {
        case latitudeColeta = "latitudeColeta"
        case longitudeColeta = "longitudeColeta"
        case latitudeEntrega = "latitudeEntrega"
        case longitudeEntrega = "longitudeEntrega"
        case destinoColeta = "destinoColeta"
        case destinoEntrega = "destinoEntrega"
        case telefone = "telefone"
        case tipodeCarga = "tipodeCarga"
        case tipoDeCaminhao = "tipoDeCaminhao"
        case valor = "valor"
    }
}
