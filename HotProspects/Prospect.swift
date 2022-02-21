//
//  Prospect.swift
//  HotProspects
//
//  Created by Dante Cesa on 2/21/22.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = "Default Name"
    var email: String = "default@email.com"
    fileprivate(set) var isContacted: Bool = false
}

@MainActor class Prospects: ObservableObject {
    let saveKey: String = "savedProspects"
    
    @Published private(set) var people: [Prospect]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedPeople = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decodedPeople
                return
            }
        }
        
        people = []
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func toggleContacted(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
