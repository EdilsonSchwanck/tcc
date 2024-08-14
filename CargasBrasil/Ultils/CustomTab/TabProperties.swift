//
//  TabProperties.swift
//  CargasBrasil
//
//  Created by Edilson Borges on 08/08/24.
//

import SwiftUI

@Observable
class TabProperties {
    var activeTab: Int = 0
    var editMode: Bool = false
    var tabs: [TabModel] = defaultOrdemTabs
    
}
