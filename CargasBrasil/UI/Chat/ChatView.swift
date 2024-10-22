//
//  ChatView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 14/08/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ChatView: View {
    var conversationId: String
    var otherUserId: String
    
    
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var sessionService: SessionServiceImpl
    @State private var currentUserImageURL: String = ""

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            HStack(alignment: .bottom, spacing: 10) {
                                if !message.isSentByCurrentUser {
                                    leftMessageView(message: message)
                                } else {
                                    rightMessageView(message: message)
                                }
                            }
                            .padding(.horizontal)
                            .id(message.id)
                        }
                    }
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .padding(.top)

            HStack(spacing: 10) {
                TextField("Digite uma mensagem...", text: $viewModel.newMessageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)

                Button(action: {
                    sendMessage()
                  
                    print("conversationId \(conversationId)")
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray5).opacity(0.5))
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .onAppear {
            fetchMessage()
            loadCurrentUserImageURL()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func leftMessageView(message: Message) -> some View {
        let destinationView = UserProfileView(
            userImageURL: message.userImageURL,
            userName: message.userName,
            typeVheicle: message.typeVheicle ?? "N/A",
            plateVheicle: message.plateVheicle ?? "N/A",
            isCompany: message.isCompany ?? false,
            cpfCnpj: message.cpfCnpj ?? "N/A"
        )

        return HStack(alignment: .bottom, spacing: 8) {
            NavigationLink(destination: destinationView) {
                ProfileImageView(imageURL: message.userImageURL)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                Text(message.userName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(message.text)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.horizontal, 5)
    }

    private func rightMessageView(message: Message) -> some View {
        let destinationView = UserProfileView(
            userImageURL: message.userImageURL,
            userName: message.userName,
            typeVheicle: message.typeVheicle ?? "N/A",
            plateVheicle: message.plateVheicle ?? "N/A",
            isCompany: message.isCompany ?? false,
            cpfCnpj: message.cpfCnpj ?? "N/A"
        )

        return HStack(alignment: .bottom, spacing: 8) { 
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(message.text)
                    .padding(10)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }

            NavigationLink(destination: destinationView) {
                ProfileImageView(imageURL: message.userImageURL)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 5)
    }
    
    private func fetchMessage() {
        guard let userDetails = sessionService.userDetails else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let conversationId = viewModel.chatService.generateConversationId(user1Id: currentUserId, user2Id: otherUserId)
        viewModel.fetchMessages(conversationId: conversationId, cpfcnpj: userDetails.cnpj)
    }
    
    private func sendMessage() {
        guard let userDetails = sessionService.userDetails else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let userName = userDetails.isCompany ? userDetails.nameCompany : userDetails.nameUser
        let isCompany = userDetails.isCompany
        let cpfCnpj = userDetails.cnpj
        let plateVheicle = userDetails.plateVheicle
        let typeVheicle = userDetails.typeVheicle

        viewModel.sendMessage(
            otherUserId: otherUserId,
            userName: userName,
            userImageURL: currentUserImageURL,
            isCompany: isCompany,
            cpfCnpj: cpfCnpj,
            plateVheicle: plateVheicle,
            typeVheicle: typeVheicle
        )
    }


    private func loadCurrentUserImageURL() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let docRef = Firestore.firestore().collection("imageUsuario").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageURL = document.data()?["imageURL"] as? String {
                    self.currentUserImageURL = imageURL
                } else {
                    print("Chave 'imageURL' não encontrada ou valor inválido")
                }
            } else {
                if let error = error {
                    print("Erro ao buscar documento: \(error.localizedDescription)")
                } else {
                    print("Documento não encontrado")
                }
            }
        }
    }
}
#Preview {
    let exampleMessages = [
        Message(
            id: "1",
            text: "Olá!",
            isSentByCurrentUser: true,
            timestamp: Date().timeIntervalSince1970 - 60,
            userName: "João",
            userImageURL: nil ,
            isCompany: false,
            cpfCnpj: "1232141241",
            plateVheicle: "234134",
            typeVheicle: "3414141"
        ),
        Message(
            id: "2",
            text: "Oi, como posso ajudar?",
            isSentByCurrentUser: false,
            timestamp: Date().timeIntervalSince1970 - 30,
            userName: "Maria",
            userImageURL: "https://example.com/image2.jpg",
            isCompany: false,
            cpfCnpj: "1232141241",
            plateVheicle: "234134",
            typeVheicle: "3414141"
        ),
        Message(
            id: "3",
            text: "Estou interessado no seu anúncio.",
            isSentByCurrentUser: true,
            timestamp: Date().timeIntervalSince1970,
            userName: "João",
            userImageURL: nil,
            isCompany: false,
            cpfCnpj: "1232141241",
            plateVheicle: "234134",
            typeVheicle: "3414141"
        )
    ]

    let viewModel = ChatViewModel()
    viewModel.messages = exampleMessages

    return ChatView(conversationId: "exampleConversationId", otherUserId: "exampleUserId")
        .environmentObject(SessionServiceImpl())
}
