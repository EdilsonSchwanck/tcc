//
//  ChatViewModel.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 14/08/24.
//

import Foundation
import Combine
import FirebaseAuth

final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var newMessageText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
     let chatService: ChatService
    
    init(chatService: ChatService = ChatServiceImpl()) {
        self.chatService = chatService
        self.observeConversations() // Iniciar a observação das conversas
    }
    
    func fetchMessages(conversationId: String, cpfcnpj: String) {
        messages.removeAll()
        chatService.fetchMessages(conversationId: conversationId, cpfcnpj: cpfcnpj)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching messages: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] newMessages in
                guard let self = self else { return }

                // Verificar se a mensagem já foi adicionada
                for newMessage in newMessages {
                    if !self.messages.contains(where: { $0.id == newMessage.id }) {
                        self.messages.append(newMessage)
                    }
                }

                // Ordenar as mensagens por timestamp
                self.messages.sort { $0.timestamp < $1.timestamp }
            }
            .store(in: &cancellables)
    }


    func sendMessage(
        otherUserId: String,
        userName: String,
        userImageURL: String?,
        isCompany: Bool,
        cpfCnpj: String?,
        plateVheicle: String?,
        typeVheicle: String?
    ) {
        guard !newMessageText.isEmpty else { return }

        chatService.sendMessage(
            text: newMessageText,
            userName: userName,
            userImageURL: userImageURL,
            isCompany: isCompany,
            cpfCnpj: cpfCnpj,
            plateVheicle: plateVheicle,
            typeVheicle: typeVheicle,
            otherUserId: otherUserId
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .failure(let error):
                print("Error sending message: \(error.localizedDescription)")
            case .finished:
                break
            }
        } receiveValue: { [weak self] in
            self?.newMessageText = ""
        }
        .store(in: &cancellables)
    }

    func observeConversations() {
        chatService.fetchConversations()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching conversations: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] conversations in
                self?.conversations = conversations
                print("Conversations updated: \(conversations.count)") // Verifique se o número de conversas está correto
                print(conversations) // Isso vai imprimir os detalhes das conversas recebidas
            }
            .store(in: &cancellables)
    }


    func deleteConversation(conversationId: String) {
        chatService.deleteConversation(conversationId: conversationId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error deleting conversation: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: {
                print("Conversation deleted successfully.")
            }
            .store(in: &cancellables)
    }

    
    
}
