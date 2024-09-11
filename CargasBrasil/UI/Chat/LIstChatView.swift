//
//  LIstCachView.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 14/08/24.
//



import SwiftUI

struct LIstChatView: View {
    @State private var conversations: [Conversation] = []
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        List {
            ForEach(conversations) { conversation in
                NavigationLink(destination: ChatView(conversationId: conversation.id, otherUserId: conversation.id)) {
                    HStack {
                        ProfileImageView(imageURL: conversation.userImageURL)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(conversation.userName)
                                .font(.headline)
                            
                            Text(conversation.lastMessage)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        if conversation.unreadMessagesCount > 0 {
                            Text("\(conversation.unreadMessagesCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(8)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .onDelete(perform: deleteConversation)
        }
        .navigationTitle("Conversas")
        .onAppear {
            viewModel.observeConversations()
        }
        .onReceive(viewModel.$conversations) { conversations in
            self.conversations = conversations
        }
    }

    // Função para deletar a conversa
    private func deleteConversation(at offsets: IndexSet) {
        offsets.forEach { index in
            let conversation = conversations[index]
            viewModel.deleteConversation(conversationId: conversation.id) // Chama o ViewModel para deletar a conversa do Firebase
        }
        conversations.remove(atOffsets: offsets) // Remove localmente
    }
}

#Preview {
    LIstChatView()
}
