//
//  CargasBrasilApp.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 25/07/24.
//

import SwiftUI

@main
struct CargasBrasilApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var launchScreenManager = LaunchScreenViewModel()
    @StateObject var sessionService = SessionServiceImpl()
    
    
    var body: some Scene {
        WindowGroup {
            if launchScreenManager.state == .completed {
                switch sessionService.state {
                    case .loggedIn:
                        Home()
                            .environmentObject(sessionService)
                    case .loggedOut:
                        LoginView()
                    }// Substitua com sua tela de login
            } else {
                LaunchScreenView()
                    .onAppear {
                        launchScreenManager.dismiss() // Inicia a transição
                    }
            }
        }
    }
}
