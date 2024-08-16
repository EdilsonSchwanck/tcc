//
//  NewJobService.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 12/08/24.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore

protocol NewJobService {
    func register(with credentials: NewJobRequest) -> AnyPublisher<Void, Error>
}

final class NewJobServiceImpl: NewJobService {
    
    func register(with credentials: NewJobRequest) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { promise in
                // Cria um identificador único para o anúncio
                let documentId = UUID().uuidString
                
                // Salva os dados do anúncio no Firestore
                self.saveJobData(documentId: documentId, credentials: credentials) { result in
                    switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private func saveJobData(documentId: String, credentials: NewJobRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let jobData = [
            "latitudeColeta": credentials.latitudeColeta,
            "longitudeColeta": credentials.longitudeColeta,
            "latitudeEntrega": credentials.latitudeEntrega,
            "longitudeEntrega": credentials.longitudeEntrega,
            "destinoColeta": credentials.destinoColeta,
            "destinoEntrega": credentials.destinoEntrega,
            "telefone": credentials.telefone,
            "tipodeCarga": credentials.tipodeCarga,
            "tipoDeCaminhao": credentials.tipoDeCaminhao,
            "valor": credentials.valor,
            "userId": credentials.userId  // Adiciona o userId ao documento
        ] as [String : Any]
        
        Firestore.firestore().collection("anunciosTrabalhos").document(documentId).setData(jobData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
