//
//  LaunchScreenViewModel.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 24/07/24.
//

import Foundation

enum LaunchScreenPhase {
    case first
    case second
    case completed
}
final class LaunchScreenViewModel: ObservableObject {
    @Published private(set) var state: LaunchScreenPhase = .first
    
    func dismiss(){
        self.state = .second
        
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + 1.80 ) {
                self.state = .completed
            }
    }
}

