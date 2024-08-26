//
//  SessionService.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 08/08/24.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

enum SessionState {
    case loggedIn
    case loggedOut
}

struct UserSessionDetails {
    let id: String  
    let nameUser: String
    let cnpj: String
    let isCompany: Bool
    let nameCompany: String
    var plateVheicle: String
    var typeVheicle: String
    
    // Adicione aqui outros campos que você deseja armazenar
}

protocol SessionService {
    var state: SessionState { get }
    var userDetails: UserSessionDetails? { get }
    init()
    func logout()
}

final class SessionServiceImpl: SessionService, ObservableObject {
    
    @Published var state: SessionState = .loggedOut
    @Published var userDetails: UserSessionDetails?
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservations()
    }
    
    deinit {
        guard let handler = handler else { return }
        Auth.auth().removeStateDidChangeListener(handler)
        print("deinit SessionServiceImpl")
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
}

private extension SessionServiceImpl {
    
    func setupObservations() {
        
        handler = Auth
            .auth()
            .addStateDidChangeListener { [weak self] _, _ in
                guard let self = self else { return }
                
                let currentUser = Auth.auth().currentUser
                self.state = currentUser == nil ? .loggedOut : .loggedIn
                
                if let uid = currentUser?.uid {
                    Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
                        guard let self = self else { return }
                        
                        if let error = error {
                            print("Erro ao obter os detalhes do usuário: \(error.localizedDescription)")
                            return
                        }
                        
                        if let data = snapshot?.data() {
                            let nameUser = data["nameUser"] as? String ?? ""
                            let cnpj = data["cpfCnpj"] as? String ?? ""
                            let isCompany = data["isCompany"] as? Bool ?? false
                            let nameCompany = data["nameCompany"] as? String ?? ""
                            let plateVheicle = data["plateVheicle"] as? String ?? ""
                            let typeVheicle = data["typeVheicle"] as? String ?? ""
                            // Adicione aqui outros campos que você deseja pegar
                            
                            DispatchQueue.main.async {
                                self.userDetails = UserSessionDetails(
                                    id: uid,  // Armazena o uid aqui
                                    nameUser: nameUser,
                                    cnpj: cnpj,
                                    isCompany: isCompany,
                                    nameCompany: nameCompany,
                                    plateVheicle: plateVheicle,
                                    typeVheicle: typeVheicle
                                )
                            }
                        }
                    }
                }
            }
    }
}
