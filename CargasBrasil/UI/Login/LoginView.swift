//  LoginView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 25/07/24.
//

import SwiftUI

struct LoginView: View {
    
  
    
    @StateObject private var viewModel = LoginViewModelImpl(
        service: LoginServiceImpl()
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 135, height: 135)
                           // .colorMultiply(.appBackground)
                            .padding(.bottom, 20)
                        
                        VStack {
                            Group {
                                CustomTextField(sfIncon: "at", hint: "E-mail", value: $viewModel.credentials.email)
                                    .keyboardType(.emailAddress)
                                CustomTextField(sfIncon: "lock", hint: "Senha", isPassword: true, value: $viewModel.credentials.password)
                            }
                            .frame(width: 330)
                            .frame(height: 38)
                            .padding(5)
                            .overlay(content: {
                                RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                            })
                            .padding(2)
                            .foregroundStyle(Color.goldBackground)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .ignoresSafeArea(.keyboard)
                        }
                        .padding(.top, 10)
                        
                        HStack {
                            Text("Não possui conta?")
                                .foregroundStyle(Color.goldBackground)
                                .font(.system(size: 16))
                            
                            NavigationLink(destination: TypeUserView()) {
                                Text(" Register-se")
                                    .foregroundStyle(Color.goldBackground)
                                    .font(.system(size: 14, weight: .bold))
                                
//                                Image("ic_arrow")
//                                    .resizable()
//                                    .frame(width: 20, height: 20)
//                                    .foregroundColor(.goldBackground)
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .padding(.horizontal, 1)
                                    .foregroundStyle(Color.goldBackground)
                            }
                            .padding(.leading, 56)
                        }
                        
                        Button(action: {
                             viewModel.login()
                        }, label: {
                            Text("Login")
                                .frame(width: 335)
                                .frame(height: 50)
                                .font(.system(size: 18, weight: .bold))
                                .background(Color.goldBackground)
                                .foregroundStyle(Color.colorLabelButton)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .ignoresSafeArea()
                        })
                        .padding(.top, 55)
                    }
                    .padding(.top, 55)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    LoginView()
}
