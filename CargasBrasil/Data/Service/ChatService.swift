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
    func fetchMessages(conversationId: String) -> AnyPublisher<[Message], Error>
    func sendMessage(conversationId: String, text: String, userName: String, userImageURL: String?) -> AnyPublisher<Void, Error>
    func fetchConversations() -> AnyPublisher<[Conversation], Error>
}

final class ChatServiceImpl: ChatService {

    private let databaseRef = Database.database().reference()

    func fetchConversations() -> AnyPublisher<[Conversation], Error> {
        let conversationsSubject = PassthroughSubject<[Conversation], Error>()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            conversationsSubject.send(completion: .finished)
            return conversationsSubject.eraseToAnyPublisher()
        }

        let messagesRef = self.databaseRef.child("messages")
        
        messagesRef.observe(.value) { snapshot in
            var conversations: [Conversation] = []

            for childSnapshot in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let conversationId = childSnapshot.key
                var lastMessage: String = ""
                var lastUserName: String = ""
                var lastUserImageURL: String?

                for (_, value) in (childSnapshot.value as? [String: Any] ?? [:]).sorted(by: { ($0.value as! [String: Any])["timestamp"] as! TimeInterval > ($1.value as! [String: Any])["timestamp"] as! TimeInterval }) {
                    if let messageDict = value as? [String: Any],
                       let userId = messageDict["userId"] as? String,
                       let userName = messageDict["userName"] as? String,
                       let userImageURL = messageDict["userImageURL"] as? String,
                       let text = messageDict["text"] as? String {
                        
                        lastMessage = text
                        lastUserName = userName
                        lastUserImageURL = userImageURL
                        
                        // Não precisa mais percorrer, já pegamos a última mensagem
                        break
                    }
                }
                
                // Adiciona ou atualiza a conversa na lista
                if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
                    conversations[index].lastMessage = lastMessage
                } else {
                    let conversation = Conversation(
                        id: conversationId,
                        userName: lastUserName,
                        lastMessage: lastMessage,
                        unreadMessagesCount: 0, // Pode ser ajustado conforme necessário
                        userImageURL: lastUserImageURL
                    )
                    conversations.append(conversation)
                }
            }

            conversationsSubject.send(conversations)
        } withCancel: { error in
            conversationsSubject.send(completion: .failure(error))
        }
        
        return conversationsSubject.eraseToAnyPublisher()
    }
    
    func fetchMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        let messagesSubject = PassthroughSubject<[Message], Error>()
        let messagesRef = self.databaseRef.child("messages").child(conversationId)
        
        messagesRef.observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let text = messageData["text"] as? String,
                  let timestamp = messageData["timestamp"] as? TimeInterval,
                  let userId = messageData["userId"] as? String,
                  let userName = messageData["userName"] as? String,
                  let userImageURL = messageData["userImageURL"] as? String else {
              return
          }

          let message = Message(
              id: snapshot.key,
              text: text,
              isSentByCurrentUser: userId == Auth.auth().currentUser?.uid,
              timestamp: timestamp,
              userName: userName,
              userImageURL: userImageURL
          )
          
          messagesSubject.send([message])
        } withCancel: { error in
            messagesSubject.send(completion: .failure(error))
        }
        
        return messagesSubject.eraseToAnyPublisher()
    }

    func sendMessage(conversationId: String, text: String, userName: String, userImageURL: String?) -> AnyPublisher<Void, Error> {
        Future { promise in
            let dbRef = self.databaseRef.child("messages").child(conversationId)
            let messageId = UUID().uuidString
            let messageData: [String: Any] = [
                "text": text,
                "timestamp": Date().timeIntervalSince1970,
                "userId": Auth.auth().currentUser?.uid ?? "",
                "userName": userName,
                "userImageURL": userImageURL ?? ""
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
}
