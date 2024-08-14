//
//  ImageUserService.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 13/08/24.
//


import Foundation
import Combine
import Firebase
import FirebaseStorage
import FirebaseFirestore

protocol ImageUserService {
    func saveUserImage(with request: ImageUserRequest, uid: String) -> AnyPublisher<Void, Error>
}

final class ImageUserServiceImpl: ImageUserService {

    func saveUserImage(with request: ImageUserRequest, uid: String) -> AnyPublisher<Void, Error> {
        
        Deferred {
            Future { promise in
                
                guard let imageData = request.imageCNH else {
                    promise(.failure(MyError.encodingError))
                    return
                }
                
                let storageRef = Storage.storage().reference().child("UserImages/\(uid).jpg")
                
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
                        
                        self.saveImageData(uid: uid, imageURL: downloadURL.absoluteString) { result in
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
    
    private func saveImageData(uid: String, imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let imageData = [
            "imageURL": imageURL
        ]
        
        Firestore.firestore().collection("imageUsuario").document(uid).setData(imageData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
