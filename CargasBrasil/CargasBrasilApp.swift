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
                contentView
                    .environmentObject(sessionService)
            } else {
                LaunchScreenView()
                    .onAppear {
                        launchScreenManager.dismiss()
                    }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch sessionService.state {
        case .loggedIn:
            Home()
        case .loggedOut:
            LoginView()
        }
    }
}
