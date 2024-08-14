//
//  RegisterStepOneView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 28/07/24.
//



import SwiftUI
import UIKit

struct RegisterStepOneView: View {
    let isCompany: Bool
    
    @State var email: String = ""
    @State var cnhCategory: String = ""
    @State var nameCompany: String = ""
    @State var cpfCnpj: String = ""
    @State var nameUser: String = ""
    @State var numberCnh: String = ""
    @State var plateVheicle: String = ""
    @State var typeVheicle: String = ""
    @State var phone: String = ""
    
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var imageCNH: UIImage?
    @State private var showCnhPicker: Bool = false

    @State private var imageDocumentVehicle: UIImage?
 
    let cnhCategories = ["A", "B", "C", "D", "E", "AB", "AC", "AD", "AE"]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack() {
                        Text("Informe os dados para cadastro")
                            .padding(.bottom, 20)
                            .padding(.top, 20)
                        
                        Group {
                            if isCompany {
                                CustomTextField(sfIncon: "at", hint: "Nome Empresa", value: $nameCompany)
                                CustomTextField(sfIncon: "at", hint: "CNPJ", value: $cpfCnpj)
                                    .keyboardType(.numberPad)
                            } else {
                                CustomTextField(sfIncon: "at", hint: "Nome completo", value: $nameUser)
                                CustomTextField(sfIncon: "at", hint: "CPF", value: $cpfCnpj)
                                    .keyboardType(.numberPad)
                                CustomTextField(sfIncon: "at", hint: "Numero CNH", value: $numberCnh)
                                    .keyboardType(.numberPad)
                                CustomTextField(sfIncon: "at", hint: "Categoria CNH", value: $cnhCategory)
                                    .onTapGesture {
                                        showCnhPicker.toggle()
                                    }
                                    .sheet(isPresented: $showCnhPicker) {
                                        VStack {
                                            Text("Selecione a Categoria da CNH")
                                                .font(.headline)
                                            Picker("Categoria CNH", selection: $cnhCategory) {
                                                ForEach(cnhCategories, id: \.self) { category in
                                                    Text(category).tag(category)
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            Button("OK") {
                                                showCnhPicker = false
                                            }
                                            .padding()
                                        }
                                        .frame(height: 300)
                                    }

                                
                                CustomTextField(sfIncon: "at", hint: "Placa veiculo", value: $plateVheicle)
                                CustomTextField(sfIncon: "at", hint: "Tipo de veiculo", value: $typeVheicle)
                            }
                            CustomTextField(sfIncon: "at", hint: "E-mail", value: $email)
                                .keyboardType(.emailAddress)
                            CustomTextField(sfIncon: "at", hint: "Telefone", value: $phone)
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
                        
                        // Image selection section
                        VStack {
                            if !isCompany {
                                Text("Agora precisamos da foto da sua Habilitação")
                                Button(action: {
                                    self.showSheet = true
                                }) {
                                    Image(uiImage: imageCNH ?? UIImage(named: "placeholder")!)
                                        .resizable()
                                        .frame(width: 300, height: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                                .buttonStyle(PlainButtonStyle()) // Ensures the button doesn't have default styling
                                .padding()
                                
                                .actionSheet(isPresented: $showSheet) {
                                    ActionSheet(title: Text("Selecione um tipo"), buttons: [
                                        .default(Text("Galeria")) {
                                            self.showImagePicker = true
                                            self.sourceType = .photoLibrary
                                        },
                                        .default(Text("Camera")) {
                                            self.showImagePicker = true
                                            self.sourceType = .camera
                                        },
                                        .cancel()
                                    ])
                                }

                            }
                             
                        }
                        

                        
                        
                    }
                    .padding(.horizontal, 15)
                }
                .scrollIndicators(.hidden)
                
                // NavigationLink to the next view with parameters
                NavigationLink(destination: RegisterStepTwoView(
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
                    isCompany: isCompany
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
        .sheet(isPresented: $showImagePicker){
            ImagePicker(image: self.$imageCNH, isShown: self.$showImagePicker, sourceType: self.sourceType)
        }
        .navigationTitle("Register")
    }
}

#Preview {
    RegisterStepOneView(isCompany: true)
}
