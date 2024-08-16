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
        Future { promise in
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                promise(.success([]))
                return
            }

            let messagesRef = self.databaseRef.child("messages")
            
            messagesRef.observeSingleEvent(of: .value) { snapshot in
                guard let snapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                    promise(.success([]))
                    return
                }

                var conversations: [Conversation] = []

                for childSnapshot in snapshots {
                    let conversationId = childSnapshot.key
                    var lastMessage: String = ""
                    var otherUserName: String = ""
                    var otherUserImageURL: String?
                    var unreadMessagesCount: Int = 0
                    var involvesCurrentUser = false

                    if let messagesDict = childSnapshot.value as? [String: Any] {
                        var conversationMessages: [[String: Any]] = []

                        // Verifica se o usuário atual está envolvido na conversa
                        for (_, value) in messagesDict {
                            guard let messageDict = value as? [String: Any],
                                  let userId = messageDict["userId"] as? String else { continue }

                            if userId == currentUserId {
                                involvesCurrentUser = true
                            } else {
                                otherUserName = messageDict["userName"] as? String ?? "Usuário"
                                otherUserImageURL = messageDict["userImageURL"] as? String
                            }

                            conversationMessages.append(messageDict)
                        }

                        // Se o usuário atual está envolvido, processa as mensagens para encontrar a última mensagem e contar as não lidas
                        if involvesCurrentUser {
                            conversationMessages.sort { ($0["timestamp"] as? TimeInterval ?? 0) > ($1["timestamp"] as? TimeInterval ?? 0) }

                            if let lastMessageDict = conversationMessages.first {
                                lastMessage = lastMessageDict["text"] as? String ?? ""
                                unreadMessagesCount = conversationMessages.filter { ($0["userId"] as? String) != currentUserId && !($0["isRead"] as? Bool ?? true) }.count
                            }

                            let conversation = Conversation(
                                id: conversationId,
                                userName: otherUserName,
                                lastMessage: lastMessage,
                                unreadMessagesCount: unreadMessagesCount,
                                userImageURL: otherUserImageURL
                            )
                            conversations.append(conversation)
                        }
                    }
                }

                promise(.success(conversations))
            } withCancel: { error in
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
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
