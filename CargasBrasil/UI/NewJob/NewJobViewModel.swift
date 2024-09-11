//
//  NewJobViewModel.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 12/08/24.
//

import Foundation
import Combine
import FirebaseFirestore

protocol NewJobViewModel {
    func create()
    var service: NewJobService { get }
    var state: JobRegistrationState { get }
    var hasError: Bool { get }
    var newJob: NewJobRequest { get }
    init(service: NewJobService)
}

final class NewJobViewModelImpl: ObservableObject, NewJobViewModel {
    
    let service: NewJobService
    @Published var state: JobRegistrationState = .na
    @Published var newJob = NewJobRequest(latitudeColeta: 0.0, longitudeColeta: 0.0, latitudeEntrega: 0.0, longitudeEntrega: 0.0, destinoColeta: "", destinoEntrega: "", telefone: "", tipodeCarga: "", tipoDeCaminhao: "", valor: " ", userId: " ", cpfCnpj: "")
    
  
    @Published var hasError: Bool = false
    


    private var subscriptions = Set<AnyCancellable>()
    
    init(service: NewJobService) {
        self.service = service
        setupErrorSubscription()
    }
    
    func create() {

        service
            .register(with: newJob)
            .sink { [weak self] res in
                switch res {
                case .failure(let error):
                    self?.state = .failed(error: error)
                default: break
                }
            } receiveValue: { [weak self] in
                self?.state = .successfullyRegistered
            }
            .store(in: &subscriptions)
    }
    
    func update(jobId: String, with updatedJob: NewJobRequest) {
            let db = Firestore.firestore()
            db.collection("anunciosTrabalhos").document(jobId).setData(updatedJob.toDictionary(), merge: true) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.state = .failed(error: error)
                    } else {
                        self.state = .successfullyRegistered
                    }
                }
            }
        }
}

private extension NewJobViewModelImpl {
    
    func setupErrorSubscription() {
        $state
            .map { state -> Bool in
                switch state {
                case .successfullyRegistered,
                     .na:
                    return false
                case .failed:
                    return true
                }
            }
            .assign(to: &$hasError)
    }
}

// Enum to represent the state of job registration
enum JobRegistrationState: Equatable {
    case na
    case successfullyRegistered
    case failed(error: Error)
    
    static func == (lhs: JobRegistrationState, rhs: JobRegistrationState) -> Bool {
        switch (lhs, rhs) {
        case (.na, .na):
            return true
        case (.successfullyRegistered, .successfullyRegistered):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                   (lhsError as NSError).code == (rhsError as NSError).code
        default:
            return false
        }
    }
}


