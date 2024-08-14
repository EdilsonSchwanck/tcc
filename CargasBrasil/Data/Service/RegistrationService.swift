import Foundation
import Combine
import Firebase
import FirebaseStorage
import FirebaseFirestore

enum MyError: Error {
    case encodingError
}

protocol RegistrationService {
    func register(with credentials: RegistrationCredentials) -> AnyPublisher<Void, Error>
}

final class RegistrationServiceImpl: RegistrationService {
    
    func register(with credentials: RegistrationCredentials) -> AnyPublisher<Void, Error> {
        
        Deferred {
            Future { promise in
                // Primeiro, cria o usuário no Firebase Authentication
                Auth.auth().createUser(withEmail: credentials.email ?? "", password: credentials.password) { res, error in
                    if let err = error {
                        promise(.failure(err))
                    } else {
                        guard let uid = res?.user.uid else {
                            promise(.failure(MyError.encodingError))
                            return
                        }
                        
                        // Salva a imagem no Firebase Storage
                        if let imageCNH = credentials.imageCNH, let imageData = imageCNH.jpegData(compressionQuality: 0.8) {
                            let storageRef = Storage.storage().reference().child("CNH/\(uid).jpg")
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
                                    
                                    // Salva os dados do usuário no Firestore
                                    self.saveUserData(uid: uid, credentials: credentials, imageURL: downloadURL.absoluteString) { result in
                                        switch result {
                                        case .success:
                                            promise(.success(()))
                                        case .failure(let error):
                                            promise(.failure(error))
                                        }
                                    }
                                }
                            }
                        } else {
                            // Salva os dados do usuário no Firestore (sem imagem)
                            self.saveUserData(uid: uid, credentials: credentials, imageURL: nil) { result in
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
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private func saveUserData(uid: String, credentials: RegistrationCredentials, imageURL: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        var userData = [
            "email": credentials.email ?? "",
            "cnhCategory": credentials.cnhCategory ?? "",
            "nameCompany": credentials.nameCompany ?? "",
            "cpfCnpj": credentials.cpfCnpj ?? "",
            "nameUser": credentials.nameUser ?? "",
            "numberCnh": credentials.numberCnh ?? "",
            "plateVheicle": credentials.plateVheicle ?? "",
            "typeVheicle": credentials.typeVheicle ?? "",
            "phone": credentials.phone ?? "",
            "isCompany": credentials.isCompany ?? false,
            "cep": credentials.cep,
            "endereco": credentials.endereco,
            "numero": credentials.numero,
            "bairro": credentials.bairro,
            "cidade": credentials.cidade,
            "estado": credentials.estado
        ] as [String : Any]
        
        if let imageURL = imageURL {
            userData["imageCNH"] = imageURL
        }
        
        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}


