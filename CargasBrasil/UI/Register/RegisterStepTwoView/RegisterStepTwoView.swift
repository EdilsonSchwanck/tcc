//
//  RegisterStepTwoView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 01/08/24.
//

import SwiftUI

struct RegisterStepTwoView: View {
    
    var email: String?
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
    
    @State var cep: String = ""
    @State var endereco: String = ""
    @State var numero: String = ""
    @State var bairro: String = ""
    @State var cidade: String = ""
    @State var estado: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack() {
                            Text("Informe os dados para cadastro")
                                .padding(.bottom, 20)
                                .padding(.top, 20)
                            
                            Group {
                                CustomTextField(sfIncon: "at", hint: "Cep", value: $cep)
                                    .keyboardType(.numberPad)
                                
                                CustomTextField(sfIncon: "at", hint: "Endereço", value: $endereco)
                                
                                CustomTextField(sfIncon: "at", hint: "Numero", value: $numero)
                                    .keyboardType(.numberPad)
                                CustomTextField(sfIncon: "at", hint: "Bairro", value: $bairro)
                                
                                CustomTextField(sfIncon: "at", hint: "Cidade", value: $cidade)
                                
                                CustomTextField(sfIncon: "at", hint: "Estado", value: $estado)
                            }
                            .frame(width: 330)
                            .frame(height: 38)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                            )
                            .padding(2)
                            .foregroundStyle(Color.goldBackground)
                            .foregroundStyle(.black)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .ignoresSafeArea(.keyboard)
                        }
                        .padding(.horizontal, 15)
                    }
                    
                    // NavigationLink to the next view with parameters
                    NavigationLink(destination: RegisterStepThreeView(
                        email: email,
                        cnhCategory: cnhCategory,
                        nameCompany: nameCompany,
                        cpfCnpj: cpfCnpj,
                        nameUser: nameUser,
                        numberCnh: numberCnh,
                        plateVheicle: plateVheicle,
                        typeVheicle: typeVheicle,
                        phone: phone,
                        imageCNH: imageCNH,
                        isCompany: isCompany,
                        cep: cep,
                        endereco: endereco,
                        numero: numero,
                        bairro: bairro,
                        cidade: cidade,
                        estado: estado
                        
                    )) {
                        Text("Próximo")
                            .frame(width: 335)
                            .frame(height: 50)
                            .font(.system(size: 18, weight: .bold))
                            .background(Color.goldBackground)
                            .foregroundStyle(Color.colorLabelButton)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .ignoresSafeArea()
                    }
                    .padding(.bottom, 10) // Adjust as needed
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .navigationTitle("Register")
    }
}

#Preview {
    RegisterStepTwoView(
        email: "",
        cnhCategory: "",
        nameCompany: "",
        cpfCnpj: "",
        nameUser: "",
        numberCnh: "",
        plateVheicle: "",
        typeVheicle: "",
        phone: "",
        imageCNH: nil,
        isCompany: false
    )
}
