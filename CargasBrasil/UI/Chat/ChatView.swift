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
                                    ProfileImageView(imageURL: message.userImageURL)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
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
                                } else {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(message.text)
                                            .padding(10)
                                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .cornerRadius(12)
                                            .foregroundColor(.white)
                                    }
                                    ProfileImageView(imageURL: message.userImageURL)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
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
            viewModel.fetchMessages(conversationId: conversationId)
            loadCurrentUserImageURL()  // Carrega a URL da imagem ao aparecer a view
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        guard let userDetails = sessionService.userDetails else { return }

        let userName = userDetails.isCompany ? userDetails.nameCompany : userDetails.nameUser
        viewModel.sendMessage(conversationId: conversationId, userName: userName, userImageURL: currentUserImageURL)
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
            userImageURL: nil // Ou você pode fornecer uma URL de exemplo, como "https://example.com/image1.jpg"
        ),
        Message(
            id: "2",
            text: "Oi, como posso ajudar?",
            isSentByCurrentUser: false,
            timestamp: Date().timeIntervalSince1970 - 30,
            userName: "Maria",
            userImageURL: "https://example.com/image2.jpg" // URL de exemplo
        ),
        Message(
            id: "3",
            text: "Estou interessado no seu anúncio.",
            isSentByCurrentUser: true,
            timestamp: Date().timeIntervalSince1970,
            userName: "João",
            userImageURL: nil // Ou uma URL realista
        )
    ]

    let viewModel = ChatViewModel()
    viewModel.messages = exampleMessages

    return ChatView(conversationId: "exampleConversationId", otherUserId: "exampleUserId")
        .environmentObject(SessionServiceImpl())  // Necessário para o ambiente de pré-visualização
}
