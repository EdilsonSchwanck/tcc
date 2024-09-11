//
//  ChatService.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 14/08/24.
//

import Foundation
import Combine
import Firebase
import FirebaseDatabase

protocol ChatService {
    func fetchMessages(conversationId: String, cpfcnpj: String) -> AnyPublisher<[Message], Error>
    func sendMessage(conversationId: String, text: String, userName: String, userImageURL: String?, isCompany: Bool, cpfCnpj: String?, plateVheicle: String?, typeVheicle: String?) -> AnyPublisher<Void, Error>
    func fetchConversations() -> AnyPublisher<[Conversation], Error>
    
    func deleteConversation(conversationId: String) -> AnyPublisher<Void, Error>
}

final class ChatServiceImpl: ChatService {

    private let databaseRef = Database.database().reference()



    func fetchConversations() -> AnyPublisher<[Conversation], Error> {
        let subject = PassthroughSubject<[Conversation], Error>()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            subject.send(completion: .finished)
            return subject.eraseToAnyPublisher()
        }

        let conversationsRef = databaseRef.child("messages")
        
        conversationsRef.observe(.value) { snapshot in
            var conversations: [Conversation] = []

            // Iterar sobre todas as conversas
            for conversationSnapshot in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                var lastMessage = ""
                var lastTimestamp: TimeInterval = 0
                var otherUserId: String?
                var otherUserName: String?
                var otherUserImageURL: String?
                var isCurrentUserInvolved = false

                // Iterar sobre todas as mensagens dentro de uma conversa
                for messageSnapshot in conversationSnapshot.children.allObjects as? [DataSnapshot] ?? [] {
                    if let messageDict = messageSnapshot.value as? [String: Any],
                       let userId = messageDict["userId"] as? String,
                       let userName = messageDict["userName"] as? String,
                       let userImageURL = messageDict["userImageURL"] as? String,
                       let text = messageDict["text"] as? String,
                       let timestamp = messageDict["timestamp"] as? TimeInterval {

                        // Pegar a última mensagem com base no timestamp
                        if timestamp > lastTimestamp {
                            lastMessage = text
                            lastTimestamp = timestamp
                        }

                        // Verificar se o currentUserId está envolvido
                        if userId == currentUserId {
                            isCurrentUserInvolved = true
                        } else {
                            // Se o currentUserId não for o remetente, é o outro participante
                            otherUserId = userId
                            otherUserName = userName
                            otherUserImageURL = userImageURL
                        }
                    }
                }

                // Adicionar a conversa apenas se o currentUserId estiver envolvido
                if isCurrentUserInvolved {
                    let conversation = Conversation(
                        id: conversationSnapshot.key,
                        userName: otherUserName ?? "", // Nome do outro usuário
                        lastMessage: lastMessage,
                        unreadMessagesCount: 0, // Ajuste conforme necessário
                        userImageURL: otherUserImageURL ?? "" // Foto do outro usuário
                    )
                    conversations.append(conversation)
                }
            }
            
            subject.send(conversations)
        } withCancel: { error in
            subject.send(completion: .failure(error))
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func fetchMessages(conversationId: String, cpfcnpj: String) -> AnyPublisher<[Message], Error> {
        let messagesSubject = PassthroughSubject<[Message], Error>()
        let messagesRef = self.databaseRef.child("messages").child(conversationId)
        
        messagesRef.observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let text = messageData["text"] as? String,
                  let timestamp = messageData["timestamp"] as? TimeInterval,
                  let userId = messageData["userId"] as? String,
                  let userName = messageData["userName"] as? String,
                  let isCompany = messageData["isCompany"] as? Bool,
                  let cpfCnpj = messageData["cpfCnpj"] as? String,
                  let plateVheicle = messageData["plateVheicle"] as? String,
                  let typeVheicle = messageData["typeVheicle"] as? String,
                  let userImageURL = messageData["userImageURL"] as? String else {
                return
            }

            let message = Message(
                id: snapshot.key,
                text: text,
                isSentByCurrentUser: userId == Auth.auth().currentUser?.uid,
                timestamp: timestamp,
                userName: userName,
                userImageURL: userImageURL,
                isCompany: isCompany,
                cpfCnpj: cpfCnpj,
                plateVheicle: plateVheicle,
                typeVheicle: typeVheicle
            )
            
            messagesSubject.send([message])
        } withCancel: { error in
            messagesSubject.send(completion: .failure(error))
        }
        
        return messagesSubject.eraseToAnyPublisher()
    }

    func sendMessage(conversationId: String, text: String, userName: String, userImageURL: String?, isCompany: Bool, cpfCnpj: String?, plateVheicle: String?, typeVheicle: String? ) -> AnyPublisher<Void, Error> {
        Future { promise in
            let dbRef = self.databaseRef.child("messages").child(conversationId)
            let messageId = UUID().uuidString
            let messageData: [String: Any] = [
                "text": text,
                "timestamp": Date().timeIntervalSince1970,
                "userId": Auth.auth().currentUser?.uid ?? "",
                "userName": userName,
                "userImageURL": userImageURL ?? "",
                "isCompany": isCompany,
                "cpfCnpj": cpfCnpj ?? "",
                "plateVheicle": plateVheicle ?? "",
                "typeVheicle": typeVheicle ?? ""
            ]

            dbRef.child(messageId).setValue(messageData) { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func deleteConversation(conversationId: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            let dbRef = self.databaseRef.child("messages").child(conversationId)

            dbRef.removeValue { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
