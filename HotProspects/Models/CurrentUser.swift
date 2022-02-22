//
//  CurrentUser.swift
//  HotProspects
//
//  Created by Dante Cesa on 2/21/22.
//

import Foundation

struct CurrentUser: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var email: String = ""
}
