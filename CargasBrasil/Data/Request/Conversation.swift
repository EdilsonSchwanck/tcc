//
//  Message.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 14/08/24.
//
import SwiftUI

import UIKit

struct Conversation: Identifiable {
    let id: String
    var userName: String
    var lastMessage: String
    var unreadMessagesCount: Int
    var userImageURL: String?
 
}
