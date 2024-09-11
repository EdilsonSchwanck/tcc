//
//  JobViewModel.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 12/08/24.
//

import Foundation
import FirebaseFirestore

class JobViewModel: ObservableObject {
    @Published var jobs = [Job]()

    private var db = Firestore.firestore()

    func fetchJobs() {
        db.collection("anunciosTrabalhos").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.jobs = documents.map { queryDocumentSnapshot -> Job in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                let destinoColeta = data["destinoColeta"] as? String ?? ""
                let destinoEntrega = data["destinoEntrega"] as? String ?? ""
                let telefone = data["telefone"] as? String ?? ""
                let tipodeCarga = data["tipodeCarga"] as? String ?? ""
                let tipoDeCaminhao = data["tipoDeCaminhao"] as? String ?? ""
                let valorFrete = data["valor"] as? String ?? "sdfs"
                let latitudeColeta = data["latitudeColeta"] as? Double ?? 0.0
                let longitudeColeta = data["longitudeColeta"] as? Double ?? 0.0
                let latitudeEntrega = data["latitudeEntrega"] as? Double ?? 0.0
                let longitudeEntrega = data["longitudeEntrega"] as? Double ?? 0.0
                let userId = data["userId"] as? String ?? ""
                let cpfcnpj = data["cpfCnpj"] as? String ?? ""
                
                
                return Job(id: id, destinoColeta: destinoColeta, destinoEntrega: destinoEntrega, telefone: telefone, tipodeCarga: tipodeCarga, tipoDeCaminhao: tipoDeCaminhao, valor: valorFrete, latitudeColeta: latitudeColeta, longitudeColeta: longitudeColeta, latitudeEntrega: latitudeEntrega, longitudeEntrega: longitudeEntrega, userId: userId, cpfCnpj: cpfcnpj)
            }
        }
    }
    
    
}
