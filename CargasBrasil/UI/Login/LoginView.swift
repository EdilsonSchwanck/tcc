//  LoginView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 25/07/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionService: SessionServiceImpl
    @StateObject private var viewModel = LoginViewModelImpl(service: LoginServiceImpl())
    @State private var showPasswordResetSheet = false
    @State private var isLoading = false // Controla o estado do ProgressView

    var body: some View {
        Group {
            if sessionService.state == .loggedIn {
                Home() 
                    .transition(.slide) // Adiciona uma transição visual
            } else {
                loginContent
            }
        }
        .onReceive(viewModel.$state) { state in
            handleStateChange(state)
        }
        .alert(isPresented: $viewModel.hasError) {
            Alert(
                title: Text("Alerta"),
                message: Text("Senha ou e-mail incorreto. Por favor, tente novamente."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showPasswordResetSheet) {
            PasswordResetView(showPasswordResetSheet: $showPasswordResetSheet)
                .presentationDetents([.medium])
        }
    }

    private var loginContent: some View {
        NavigationStack{
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Autenticando...")
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .goldBackground))
                } else {
                    ScrollView {
                        VStack {
                            Image("logo")
                                .resizable()
                                .frame(width: 135, height: 135)
                                .padding(.bottom, 20)
                            
                            VStack {
                                Group {
                                    CustomTextField(sfIncon: "at", hint: "E-mail", value: $viewModel.credentials.email)
                                        .keyboardType(.emailAddress)
                                    
                                    CustomTextField(sfIncon: "lock", hint: "Senha", isPassword: true, value: $viewModel.credentials.password)
                                }
                                .frame(width: 330, height: 38)
                                .padding(5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                                }
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
                                    Text("Register-se")
                                        .foregroundStyle(Color.goldBackground)
                                        .font(.system(size: 14, weight: .bold))
                                    
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .padding(.horizontal, 1)
                                        .foregroundStyle(Color.goldBackground)
                                }
                                .padding(.leading, 56)
                            }
                            
                            Button(action: handleLogin) {
                                Text("Login")
                                    .frame(width: 335, height: 50)
                                    .font(.system(size: 18, weight: .bold))
                                    .background(Color.goldBackground)
                                    .foregroundStyle(Color.colorLabelButton)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .ignoresSafeArea()
                            }
                            .padding(.top, 55)
                            
                            Button(action: {
                                showPasswordResetSheet.toggle()
                            }) {
                                Text("Esqueceu sua senha?")
                                    .foregroundColor(Color.goldBackground)
                            }
                            .padding(.top, 10)
                        }
                        .padding(.top, 55)
                    }
                }
            }
            
        }
    }

    private func handleLogin() {
        isLoading = true // Exibe o ProgressView
        viewModel.login()
    }

    private func handleStateChange(_ state: LoginState) {
        switch state {
        case .successfullyLoggedIn:
            sessionService.state = .loggedIn // Atualiza o estado para 'loggedIn'
            clearPasswordField() // Limpa o campo de senha após o login
            isLoading = false // Oculta o ProgressView
        case .failed:
            isLoading = false // Oculta o ProgressView em caso de erro
        case .na:
            break // Não faz nada para o estado inicial
        }
    }

    private func clearPasswordField() {
        viewModel.credentials.password = "" // Limpa a senha após o login
    }
}

#Preview {
    LoginView()
}
