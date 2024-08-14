//
//  RegistrationCredentials.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 02/08/24.
//

import UIKit

class RegistrationCredentials: Encodable {
    var email: String?
    var password: String
    var cnhCategory: String?
    var nameCompany: String?
    var cpfCnpj: String?
    var nameUser: String?
    var numberCnh: String?
    var plateVheicle: String?
    var typeVheicle: String?
    var phone: String?
    var imageCNH: UIImage?
    let isCompany: Bool?
    
    var cep: String
    var endereco: String
    var numero: String
    var bairro: String
    var cidade: String
    var estado: String
    
    
    init(email: String? = nil, password: String, cnhCategory: String? = nil, nameCompany: String? = nil, cpfCnpj: String? = nil, nameUser: String? = nil, numberCnh: String? = nil, plateVheicle: String? = nil, typeVheicle: String? = nil, phone: String? = nil, imageCNH: UIImage? = nil, isCompany: Bool?, cep: String, endereco: String, numero: String, bairro: String, cidade: String, estado: String) 
    {
        self.email = email
        self.password = password
        self.cnhCategory = cnhCategory
        self.nameCompany = nameCompany
        self.cpfCnpj = cpfCnpj
        self.nameUser = nameUser
        self.numberCnh = numberCnh
        self.plateVheicle = plateVheicle
        self.typeVheicle = typeVheicle
        self.phone = phone
        self.imageCNH = imageCNH
        self.isCompany = isCompany
        self.cep = cep
        self.endereco = endereco
        self.numero = numero
        self.bairro = bairro
        self.cidade = cidade
        self.estado = estado
    }
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case password = "passoword"
        case cnhCategory = "categoriaCNH"
        case nameCompany = "nomeEmpresa"
        case cpfCnpj = "cpfCnpj"
        case nameUser = "NomeUsuario"
        case numberCnh = "NumeroCNH"
        case plateVheicle = "placaVeichulo"
        case typeVheicle = "tipoVeiculo"
        case phone = "telefone"
        case isCompany = "empresa"
        case cep = "cep"
        case endereco = "endereco"
        case numero = "numero"
        case bairro = "bairro"
        case cidade = "cidade"
        case estado = "estado"
    }
}

