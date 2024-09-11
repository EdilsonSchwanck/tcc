//
//  CardAssessmentProfile.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 19/08/24.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


struct UserProfileView: View {
    let userImageURL: String?
    let userName: String
    let typeVheicle: String
    let plateVheicle: String
    let isCompany: Bool
    let cpfCnpj: String

    @State private var profileImage: UIImage? = nil
    @State private var profileImageUser: UIImage? = nil
    @State private var assessmentText: String = ""
    @State private var rating: Int = 0
    @State private var showAlert = false
    @State private var assessments: [Assessment] = []
    @State private var averageRating: Double = 0.0
    @StateObject private var viewModel = UserProfileViewModel()
    @EnvironmentObject var sessionService: SessionServiceImpl
    
    private var isSelfProfile: Bool {
           guard let userDetails = sessionService.userDetails else { return false }
           return userDetails.isCompany ? userDetails.cnpj == cpfCnpj : userDetails.nameUser == userName
       }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Foto do usuário, nome e veículo
            HStack(alignment: .top, spacing: 16) {
                if let imageURL = userImageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(userName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if isCompany {
                        Text("CNPJ: \(cpfCnpj)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Veículo: \(typeVheicle)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Placa: \(plateVheicle)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        ForEach(0..<5) { star in
                            Image(systemName: star < Int(averageRating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Avaliações do usuário
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(assessments) { assessment in
                        CardAssessmentProfile(
                            profileImageURL: assessment.imageURL,
                            userName: assessment.nameUserAssessmet,
                            reviewText: assessment.textAssessment,
                            starRating: assessment.nota
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            // Seção de Avaliação
            if !isSelfProfile {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Avalie \(userName)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack {
                                CustomTextField(sfIncon: "at", hint: "Escreva sua avaliação...", value: $assessmentText)
                                    .frame(width: 330)
                                    .frame(height: 38)
                                    .padding(5)
                                    .overlay(content: {
                                        RoundedRectangle(cornerRadius: 8).stroke(Color.goldBackground, lineWidth: 1)
                                    })
                                    .padding(2)
                                    .foregroundStyle(Color.goldBackground)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .ignoresSafeArea(.keyboard)
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Nota:")
                                    .font(.headline)
                                HStack {
                                    ForEach(0..<5) { star in
                                        Image(systemName: star < rating ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .onTapGesture {
                                                rating = star + 1
                                            }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                submitAssessment()
                            }) {
                                Text("Enviar Avaliação")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    Spacer()
                }
                .navigationTitle("Perfil")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.loadAssessments(for: userName)
                    viewModel.calculateAverageRating(for: userName)
                }
                .onReceive(viewModel.$assessments, perform: { assessments in
                    self.assessments = assessments
                })
                .onReceive(viewModel.$averageRating, perform: { averageRating in
                    self.averageRating = averageRating
                })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Avaliação Enviada"), message: Text("Obrigado por sua avaliação!"), dismissButton: .default(Text("OK")))
                }
            }
    
    private func submitAssessment() {
           guard let userDetails = sessionService.userDetails else { return }
         
           // Utilize o nome do usuário logado para a avaliação
           let nameUserAssessment = userDetails.isCompany ? userDetails.nameCompany : userDetails.nameUser
           
           // Carregar a imagem do usuário logado
           loadProfileImageFromFirebase { userImage in
               guard let userImage = userImage else {
                   print("Erro ao carregar a imagem do usuário logado")
                   return
               }
               
               let request = AssessmentRequest(imageCNH: userImage, textAssessment: assessmentText, nota: rating, nameUser: userName, nameUserAssessmet: nameUserAssessment)
               viewModel.submitAssessment(request: request)
               showAlert = true
               assessmentText = ""
               rating = 0
           }
       }

       private func loadProfileImageFromFirebase(completion: @escaping (UIImage?) -> Void) {
           guard let uid = Auth.auth().currentUser?.uid else { return }
           
           let docRef = Firestore.firestore().collection("imageUsuario").document(uid)
           docRef.getDocument { (document, error) in
               if let document = document, document.exists {
                   if let imageURL = document.data()?["imageURL"] as? String {
                       self.downloadImage(from: imageURL, completion: completion)
                   } else {
                       print("Chave 'imageURL' não encontrada ou valor inválido")
                       completion(nil)
                   }
               } else {
                   if let error = error {
                       print("Erro ao buscar documento: \(error.localizedDescription)")
                   } else {
                       print("Documento não encontrado")
                   }
                   completion(nil)
               }
           }
       }

       private func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
           guard let url = URL(string: urlString) else {
               completion(nil)
               return
           }
           
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let data = data, let image = UIImage(data: data) {
                   completion(image)
               } else {
                   completion(nil)
               }
           }.resume()
       }
       
       
       

       
       
       
       private func loadImage(from urlString: String?, completion: @escaping (UIImage?) -> Void) {
           guard let urlString = urlString, let url = URL(string: urlString) else {
               completion(nil)
               return
           }
           
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let data = data, let image = UIImage(data: data) {
                   completion(image)
               } else {
                   completion(nil)
               }
           }.resume()
       }
       
       
   }


#Preview {
    UserProfileView(userImageURL: nil, userName: "João", typeVheicle: "Caminhão XYZ", plateVheicle: "ABC1234", isCompany: false, cpfCnpj: "4141414141")
}
