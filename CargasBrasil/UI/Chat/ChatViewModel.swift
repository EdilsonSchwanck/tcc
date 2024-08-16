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
    }
    
    func fetchMessages(conversationId: String) {
            chatService.fetchMessages(conversationId: conversationId)
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

        func sendMessage(conversationId: String, userName: String, userImageURL: String?) {
            guard !newMessageText.isEmpty else { return }
            
            chatService.sendMessage(conversationId: conversationId, text: newMessageText, userName: userName, userImageURL: userImageURL)
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

    func fetchConversations() {
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
                print("Conversations updated: \(conversations.count)")
            }
            .store(in: &cancellables)
    }
}
