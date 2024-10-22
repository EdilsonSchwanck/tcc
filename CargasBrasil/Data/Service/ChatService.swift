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
    func sendMessage(text: String, userName: String, userImageURL: String?, isCompany: Bool, cpfCnpj: String?, plateVheicle: String?, typeVheicle: String?, otherUserId: String) -> AnyPublisher<Void, Error>
    func fetchConversations() -> AnyPublisher<[Conversation], Error>
    func deleteConversation(conversationId: String) -> AnyPublisher<Void, Error>
    
    // Adicionando a assinatura do método
    func generateConversationId(user1Id: String, user2Id: String) -> String
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

            for conversationSnapshot in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let participants = conversationSnapshot.key.split(separator: "-").map(String.init)

                guard participants.contains(currentUserId) else { continue }

                let otherUserId = participants.first { $0 != currentUserId } ?? ""

                var lastMessage = ""
                var lastTimestamp: TimeInterval = 0
                var otherUserName: String = "Desconhecido"
                var otherUserImageURL: String = ""

                // Iterar sobre as mensagens para capturar a última mensagem e identificar o remetente
                for messageSnapshot in conversationSnapshot.children.allObjects as? [DataSnapshot] ?? [] {
                    if let messageDict = messageSnapshot.value as? [String: Any],
                       let userId = messageDict["userId"] as? String,
                       let userName = messageDict["userName"] as? String,
                       let userImageURL = messageDict["userImageURL"] as? String,
                       let text = messageDict["text"] as? String,
                       let timestamp = messageDict["timestamp"] as? TimeInterval {

                        // Captura a última mensagem e o timestamp mais recente
                        if timestamp > lastTimestamp {
                            lastMessage = text
                            lastTimestamp = timestamp
                        }

                        // Se o `userId` é do outro usuário, capturamos seu nome e imagem
                        if userId == otherUserId {
                            otherUserName = userName
                            otherUserImageURL = userImageURL
                        }
                    }
                }

                let conversation = Conversation(
                    id: conversationSnapshot.key,
                    userName: otherUserName,  // Exibe sempre o nome do outro usuário
                    lastMessage: lastMessage,
                    unreadMessagesCount: 0,
                    userImageURL: otherUserImageURL
                )
                conversations.append(conversation)
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
    
    func generateConversationId(user1Id: String, user2Id: String) -> String {
            let sortedIds = [user1Id, user2Id].sorted()
            return sortedIds.joined(separator: "-")
        }
    
    
    func sendMessage(
        text: String,
        userName: String,
        userImageURL: String?,
        isCompany: Bool,
        cpfCnpj: String?,
        plateVheicle: String?,
        typeVheicle: String?,
        otherUserId: String
    ) -> AnyPublisher<Void, Error> {
        Future { promise in
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                promise(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Usuário não autenticado."])))
                return
            }

            let conversationId = self.generateConversationId(user1Id: currentUserId, user2Id: otherUserId)
            let dbRef = self.databaseRef.child("messages").child(conversationId)
            let messageId = UUID().uuidString

            let messageData: [String: Any] = [
                "text": text,
                "timestamp": Date().timeIntervalSince1970,
                "userId": currentUserId,
                "userName": userName,  // Nome do usuário atual
                "userImageURL": userImageURL ?? "",
                "isCompany": isCompany,
                "cpfCnpj": cpfCnpj ?? "",
                "plateVheicle": plateVheicle ?? "",
                "typeVheicle": typeVheicle ?? ""
                 // Nome da empresa ou do usuário
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
    

//    func sendMessage(conversationId: String, text: String, userName: String, userImageURL: String?, isCompany: Bool, cpfCnpj: String?, plateVheicle: String?, typeVheicle: String? ) -> AnyPublisher<Void, Error> {
//        Future { promise in
//            let dbRef = self.databaseRef.child("messages").child(conversationId)
//            let messageId = UUID().uuidString
//            let messageData: [String: Any] = [
//                "text": text,
//                "timestamp": Date().timeIntervalSince1970,
//                "userId": Auth.auth().currentUser?.uid ?? "",
//                "userName": userName,
//                "userImageURL": userImageURL ?? "",
//                "isCompany": isCompany,
//                "cpfCnpj": cpfCnpj ?? "",
//                "plateVheicle": plateVheicle ?? "",
//                "typeVheicle": typeVheicle ?? ""
//            ]
//
//            dbRef.child(messageId).setValue(messageData) { error, _ in
//                if let error = error {
//                    promise(.failure(error))
//                } else {
//                    promise(.success(()))
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
    
    
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
