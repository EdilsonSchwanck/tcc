//
//  job.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 12/08/24.
//

import Foundation
struct Job: Identifiable {
    
    var id: String
    var destinoColeta: String
    var destinoEntrega: String
    var telefone: String
    var tipodeCarga: String
    var tipoDeCaminhao: String
    var valor: String
    var latitudeColeta: Double
    var longitudeColeta: Double
    var latitudeEntrega: Double
    var longitudeEntrega: Double
    var userId: String
    var cpfCnpj: String
    var nomeEmpresa: String
}
