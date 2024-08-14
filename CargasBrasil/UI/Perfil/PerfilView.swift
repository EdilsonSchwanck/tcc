//
//  PerfilView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 08/08/24.
//

import SwiftUI

struct PerfilView: View {
    @EnvironmentObject var sessionService: SessionServiceImpl
    
    var body: some View {
        VStack {
            // Informações do perfil do usuário
            Text(sessionService.userDetails?.nameUser ?? "Nome do Usuário")
                .font(.largeTitle)
                .padding()
            
            // Botão de logout
            Button(action: {
                sessionService.logout()
            }) {
                Text("Sair")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PerfilView().environmentObject(SessionServiceImpl())
}
