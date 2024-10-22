//
//  AssessmentService.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 27/08/24.
//

import Foundation
import Combine
import Firebase
import FirebaseStorage
import FirebaseFirestore

// Defina o protocolo para o serviço de avaliação
protocol AssessmentService {
    func saveAssessment(with request: AssessmentRequest, uid: String) -> AnyPublisher<Void, Error>
    func fetchAssessments(for userId: String) -> AnyPublisher<[Assessment], Error>
    func calculateAverageRating(for userId: String) -> AnyPublisher<Double, Error>
}

// Implementação do serviço de avaliação
final class AssessmentServiceImpl: AssessmentService {

    func saveAssessment(with request: AssessmentRequest, uid: String) -> AnyPublisher<Void, Error> {
        
        Deferred {
            Future { promise in
                
                guard let imageData = request.imageCNH else {
                    promise(.failure(MyError.encodingError))
                    return
                }
                
                // Defina o caminho de armazenamento para a imagem de avaliação
                let storageRef = Storage.storage().reference().child("Assessments/\(uid)_\(UUID().uuidString).jpg")
                
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }
                        
                        guard let downloadURL = url else {
                            promise(.failure(MyError.encodingError))
                            return
                        }
                        
                        // Salve os dados de avaliação (imagem, texto, nome do usuário e nota) no Firestore
                        self.saveAssessmentData(uid: uid, imageURL: downloadURL.absoluteString, request: request) { result in
                            switch result {
                            case .success:
                                promise(.success(()))
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private func saveAssessmentData(uid: String, imageURL: String, request: AssessmentRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let assessmentData = [
            "imageURL": imageURL,
            "textAssessment": request.textAssessment ?? "",
            "nota": request.nota ?? 0,
            "nomeUsuario": request.nameUser ?? "",
            "nameUserAssessmet" : request.nameUserAssessmet ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ] as [String : Any]
        
        Firestore.firestore().collection("assessments").document(uid).collection("userAssessments").addDocument(data: assessmentData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchAssessments(for userId: String) -> AnyPublisher<[Assessment], Error> {
        guard !userId.isEmpty else {
            return Fail(error: NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "O caminho do documento não pode estar vazio."]))
                .eraseToAnyPublisher()
        }

        return Future { promise in
            Firestore.firestore()
                .collection("assessments")
                .document(userId)  // Verificar se o userId é válido e não vazio
                .collection("userAssessments")
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("Nenhum documento encontrado para o usuário \(userId).")
                        promise(.success([]))
                        return
                    }

                    let assessments = documents.compactMap { document -> Assessment? in
                        let data = document.data()
                        guard
                            let imageURL = data["imageURL"] as? String,
                            let textAssessment = data["textAssessment"] as? String,
                            let nota = data["nota"] as? Int,
                            let nameUserAssessmet = data["nameUserAssessmet"] as? String,
                            let nomeUsuario = data["nomeUsuario"] as? String
                        else {
                            print("Dados incompletos no documento: \(document.documentID)")
                            return nil
                        }

                        return Assessment(
                            imageURL: imageURL,
                            textAssessment: textAssessment,
                            nota: nota,
                            nomeUsuario: nomeUsuario,
                            nameUserAssessmet: nameUserAssessmet
                        )
                    }

                    promise(.success(assessments))
                }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func calculateAverageRating(for userId: String) -> AnyPublisher<Double, Error> {
        fetchAssessments(for: userId)
            .map { assessments in
                let total = assessments.reduce(0) { $0 + $1.nota }
                return assessments.isEmpty ? 0.0 : Double(total) / Double(assessments.count)
            }
            .eraseToAnyPublisher()
    }
}
