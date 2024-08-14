//
//  TypeUserView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 28/07/24.
//

import SwiftUI

struct TypeUserView: View {
  
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                VStack {
                    Text("Selecione o seu perfil")
                        .padding(.top, 50)
                    
                    Divider()
                        .background(Color.goldBackground)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // Navegação para a tela com o parâmetro true\
//                        HStack {
//                            
//                          
//                            
//                            Image("erp")
//                                .resizable()
//                                .frame(width: 35, height: 35)
//                                .padding(.horizontal, 20)
//                            
//                            Text("Empresa")
//                                .padding(.horizontal, -20)
//                                .foregroundStyle(Color.goldBackground)
//                            
//                            Spacer()
//                            
//                            Image(systemName: "arrow.right")
//                                .resizable()
//                                .frame(width: 15, height: 15)
//                                .padding(.horizontal, 20)
//                                .foregroundStyle(Color.goldBackground)
//                            
//                            
//                        }
                    HStack {
                      
                        
                        NavigationLink(destination: RegisterStepOneView(isCompany: true)) {
                            Image("erp")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .padding(.horizontal, -47)
                            
                            Text("Empresa")
                                .padding(.horizontal, -15)
                                .foregroundStyle(Color.goldBackground)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(.horizontal, 20)
                                .foregroundStyle(Color.goldBackground)
                        }
                        .padding(.leading, 56)
                    }
                    .padding(.top, 5.0)

//
                    
                    Divider()
                        .background(Color.goldBackground)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    // Navegação para a tela com o parâmetro false
                   
                        HStack {
                            
                            NavigationLink(destination: RegisterStepOneView(isCompany: false)) {
                                
                                Image("caminhao")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .padding(.horizontal, 10)
                                
                                Text("Motorista")
                                    .padding(.horizontal, -11)
                                    .foregroundStyle(Color.goldBackground)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .padding(.horizontal, 20)
                                    .foregroundStyle(Color.goldBackground)
                            }
                        }
                        .padding(.top, 5.0)
                    
                    
                    Divider()
                        .background(Color.goldBackground)
                        .padding(.horizontal)
                        .padding(.top, 5)
                }
                .padding(.bottom, 500)
            }
            .navigationTitle("Tipo de usuário")
        }
    }
}

#Preview {
    TypeUserView()
}
