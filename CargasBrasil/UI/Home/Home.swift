//
//  Home.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 08/08/24.
//


import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct Home: View {
    @StateObject var viewModel = HomeViewModelImpl(service: ImageUserServiceImpl())
    
    @State private var selectedTab = 0
    @EnvironmentObject var sessionService: SessionServiceImpl
    
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var profileImage: UIImage? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        // Profile Image
                        Button(action: {
                            self.showSheet = true
                        }) {
                            Image(uiImage: profileImage ?? UIImage(named: "placeholder")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        }
                        .actionSheet(isPresented: $showSheet) {
                            ActionSheet(title: Text("Selecione um tipo"), buttons: [
                                .default(Text("Galeria")) {
                                    self.showImagePicker = true
                                    self.sourceType = .photoLibrary
                                },
                                .default(Text("Camera")) {
                                    self.showImagePicker = true
                                    self.sourceType = .camera
                                },
                                .cancel()
                            ])
                        }
                        .padding(.leading)
                        .onChange(of: profileImage) { newImage in
                            if let image = newImage {
                                viewModel.imageRequest = ImageUserRequest(imageCNH: image)
                                viewModel.uploadImage()
                            }
                        }

                        // Greeting
                        Text(displayedName())
                            .font(.title2)
                            .padding(.leading, 8)

                        Spacer()

                        // Chat Button
                        NavigationLink(destination: LIstChatView()) {
                            Image(systemName: "message.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.trailing)
                                .foregroundColor(.goldBackground)
                        }
                    }
                    .padding(.top, 12)

                    // TabView
                    TabView(selection: $selectedTab) {
                        ListJobView()
                            .tabItem {
                                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                                Text("Início")
                            }
                            .tag(0)
                        
                        // Mostrar apenas para usuários do tipo "empresa"
                        if sessionService.userDetails?.isCompany == true {
                            NewJobView()
                                .tabItem {
                                    Image(systemName: selectedTab == 1 ? "plus.circle.fill" : "plus.circle.fill")
                                    Text("Anunciar")
                                }
                                .tag(1)
                            
                            MyPostJobsView()
                                .tabItem {
                                    Image(systemName: selectedTab == 2 ? "doc.plaintext" : "doc.plaintext")
                                    Text("Meus Anúncios")
                                }
                                .tag(2)
                        }

                        PerfilView()
                            .tabItem {
                                Image(systemName: selectedTab == (sessionService.userDetails?.isCompany == true ? 3 : 1) ? "person.fill" : "person")
                                Text("Perfil")
                            }
                            .tag(sessionService.userDetails?.isCompany == true ? 3 : 1)
                    }
                    .accentColor(.goldBackground)
                    .font(.headline)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$profileImage, isShown: self.$showImagePicker, sourceType: self.sourceType)
            }
            .onAppear {
                loadProfileImageFromFirebase()
            }
        }
    }
    
    private func displayedName() -> String {
        guard let userDetails = sessionService.userDetails else {
            return "Carregando..."
        }
        return "Olá \(userDetails.isCompany ? userDetails.nameCompany : userDetails.nameUser)"
    }
    
    private func loadProfileImageFromFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docRef = Firestore.firestore().collection("imageUsuario").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageURL = document.data()?["imageURL"] as? String {
                    downloadImage(from: imageURL)
                }
            } else if let error = error {
                print("Erro ao buscar documento: \(error.localizedDescription)")
            }
        }
    }

    private func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }.resume()
    }
}


#Preview {
    Home().environmentObject(SessionServiceImpl())
}
