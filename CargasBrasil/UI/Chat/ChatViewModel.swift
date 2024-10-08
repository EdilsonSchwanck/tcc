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
    
    private let chatService: ChatService
    
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
                self?.messages.append(contentsOf: newMessages)
                self?.messages.sort { $0.timestamp < $1.timestamp } // Garantir que as mensagens estejam em ordem cronológica
            }
            .store(in: &cancellables)
    }

    func sendMessage(conversationId: String, userName: String, userImageURL: String?, isCompany: Bool, cpfCnpj: String?, plateVheicle: String?, typeVheicle: String?) {
        guard !newMessageText.isEmpty else { return }
        
        chatService.sendMessage(conversationId: conversationId, text: newMessageText, userName: userName, userImageURL: userImageURL, isCompany: isCompany, cpfCnpj: cpfCnpj, plateVheicle: plateVheicle, typeVheicle: typeVheicle)
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
