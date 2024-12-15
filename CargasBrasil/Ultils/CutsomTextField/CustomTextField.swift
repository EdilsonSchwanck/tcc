//
//  CustomTextField.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 27/07/24.
//

import SwiftUI

struct CustomTextField: View {
    
    var sfIncon: String
    var iconTint: Color = Color.goldBackground
    var hint: String
    var isPassword: Bool = false
    @Binding var value: String
    @State private var showPassword: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8, content: {
            Image(systemName: sfIncon)
                .foregroundStyle(iconTint)
                .frame(width: 30)
                .offset(y: 2)
            
           
                VStack(alignment: .leading, spacing: 8, content: {
                    
                    if isPassword {
                        Group{
                            if showPassword {
                                TextField("", text: $value, prompt: Text(hint).foregroundColor(Color.goldBackground))
                                   
                                    
                                   
                            }else{
                                SecureField("", text: $value, prompt: Text(hint).foregroundColor(Color.goldBackground))
                                   
                            }
                            
                        }
                        
                    }else{
                        TextField("", text: $value, prompt: Text(hint).foregroundColor(Color.goldBackground))
                           
                    }

   
                })
                .overlay(alignment: .trailing) {
                    if isPassword {
                        Button(action: {
                            withAnimation{
                                showPassword.toggle()
                            }
                        }, label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(Color.goldBackground)
                                .padding()
                                .contentShape(.rect)
                        })
                    }
                }
           
        })
            
        
    }
}

