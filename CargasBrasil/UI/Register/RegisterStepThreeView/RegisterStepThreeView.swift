//
//  RegisterStepThreeView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 02/08/24.
//

import SwiftUI


struct RegisterStepThreeView: View {
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
    
    var cep: String
    var endereco: String
    var numero: String
    var bairro: String
    var cidade: String
    var estado: String
    
    @StateObject private var viewModel = RegistrationViewModelImpl(service: RegistrationServiceImpl())
    @State private var showSuccessAlert = false
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        Text("Informe os dados para cadastro")
                            .padding(.bottom, 20)
                            .padding(.top, 20)
                        
                        Group {
                            CustomTextField(sfIncon: "lock", hint: "Senha", isPassword: true, value: $password)
                            CustomTextField(sfIncon: "lock", hint: "Confirmar Senha", isPassword: true, value: $confirmPassword)
                        }
                        .frame(width: 330)
                        .frame(height: 38)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                        )
                        .padding(2)
                        .foregroundStyle(Color.goldBackground)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .ignoresSafeArea(.keyboard)
                    }
                    .padding(.horizontal, 15)
                }
                
                Button(action: {
                    if password == confirmPassword {
                        viewModel.newUser = RegistrationCredentials(
                            email: email,
                            password: password,
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
                        )
                        viewModel.create()
                    } else {
                        // Handle password mismatch
                    }
                }, label: {
                    Text("Cadastrar")
                        .frame(width: 335)
                        .frame(height: 50)
                        .font(.system(size: 18, weight: .bold))
                        .background(Color.goldBackground)
                        .foregroundStyle(Color.colorLabelButton)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .ignoresSafeArea()
                })
                .padding(.bottom, 10)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Cadastro realizado com sucesso!"),
                    message: Text("Agora você pode realizar o login no app."),
                    dismissButton: .default(Text("Certo!"), action: {
                        navigateToLogin()
                    })
                )
            }
            .onChange(of: viewModel.state) { state in
                if case .successfullyRegistered = state {
                    showSuccessAlert = true
                }
            }
        }
        .navigationTitle("Register")
    }
    
    private func navigateToLogin() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.makeKeyAndVisible()
            }
        }
    }
}

#Preview {
    RegisterStepThreeView(
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
        isCompany: false,
        cep: "",
        endereco: "",
        numero: "",
        bairro: "",
        cidade: "",
        estado: ""
    )
}
