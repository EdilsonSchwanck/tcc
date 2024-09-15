//
//  PasswordResetView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 15/09/24.
//

import SwiftUI
import Firebase

import SwiftUI
import Firebase

struct PasswordResetView: View {
    @Binding var showPasswordResetSheet: Bool // Para controlar o fechamento
    @State private var email: String = ""
    @State private var showingAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack {
                
                HStack {
                    Spacer()
                    Button(action: {
                        showPasswordResetSheet.toggle()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.goldBackground)
                            .padding()
                    }
                }
                
                Spacer()
                
                Text("Recuperar Senha")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.goldBackground)
                
                // CustomTextField para e-mail
                CustomTextField(sfIncon: "at", hint: "Digite seu e-mail", value: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                    })
                    .foregroundStyle(Color.goldBackground)
                    .padding(.horizontal, 20)
                
                // Botão para enviar o e-mail de recuperação
                Button(action: {
                    sendPasswordReset()
                }) {
                    Text("Enviar e-mail de recuperação")
                        .frame(width: 280, height: 44)
                        .background(Color.goldBackground)
                        .foregroundColor(Color.colorLabelButton)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.appBackground)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Aviso"),
                message: Text(errorMessage ?? "E-mail de recuperação enviado! Verifique sua caixa de entrada."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = nil
            }
            showingAlert = true
        }
    }
}

#Preview {
    // Criar um estado temporário para o preview
    StateWrapper()
}

struct StateWrapper: View {
    @State private var showPasswordResetSheet = false
    
    var body: some View {
        PasswordResetView(showPasswordResetSheet: $showPasswordResetSheet)
    }
}
