//
//  HomeViewModel.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 13/08/24.
//


import Foundation
import Combine
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

protocol HomeViewModel {
    func uploadImage()
    func fetchImage()
    var service: ImageUserService { get }
    var state: ImageUploadState { get }
    var hasError: Bool { get }
    var imageRequest: ImageUserRequest { get }
    var imageResponse: ImageUserResponse? { get }
    init(service: ImageUserService)
}

final class HomeViewModelImpl: ObservableObject, HomeViewModel {
    
    let service: ImageUserService
    @Published var state: ImageUploadState = .na
    @Published var imageRequest = ImageUserRequest()
    @Published var imageResponse: ImageUserResponse?
    @Published var hasError: Bool = false

    private var subscriptions = Set<AnyCancellable>()
    
    init(service: ImageUserService) {
        self.service = service
        setupErrorSubscription()
    }
    
    func uploadImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.state = .failed(error: MyError.encodingError)
            return
        }
        
        service
            .saveUserImage(with: imageRequest, uid: uid)
            .sink { [weak self] res in
                switch res {
                case .failure(let error):
                    self?.state = .failed(error: error)
                default: break
                }
            } receiveValue: { [weak self] in
                self?.state = .successfullyUploaded
                self?.fetchImage()  // Fetch the image after successful upload
            }
            .store(in: &subscriptions)
    }
    
    func fetchImage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                if let imageURL = document.data()?["profileImageURL"] as? String {
                    self?.downloadImage(from: imageURL, id: uid)
                }
            } else {
                print("Documento não encontrado")
            }
        }
    }
    
    private func downloadImage(from urlString: String, id: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageResponse = ImageUserResponse(id: id, image: image)
                }
            }
        }.resume()
    }
}

private extension HomeViewModelImpl {
    
    func setupErrorSubscription() {
        $state
            .map { state -> Bool in
                switch state {
                case .successfullyUploaded,
                     .na:
                    return false
                case .failed:
                    return true
                }
            }
            .assign(to: &$hasError)
    }
}

enum ImageUploadState {
    case na
    case successfullyUploaded
    case failed(error: Error)
}
