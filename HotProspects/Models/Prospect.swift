//
//  Prospect.swift
//  HotProspects
//
//  Created by Dante Cesa on 2/21/22.
//

import SwiftUI

class Prospect: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String = "Default Name"
    var email: String = "default@email.com"
    var dateAdded: Date = Date.now
    fileprivate(set) var isContacted: Bool = false
    
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor class Prospects: ObservableObject {
    let saveKey: String = "savedProspects"
    
    @Published private(set) var people: [Prospect]
    
    init() {
        if let data = try? Data(contentsOf: FileManager.documentsDirectory.appendingPathComponent("prospects")) {
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
    
    func delete(_ prospect: Prospect) {
        for (index, person) in people.enumerated() {
            if prospect == person {
                people.remove(at: index)
                save()
            }
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            do {
                try encoded.write(to: FileManager.documentsDirectory.appendingPathComponent("prospects"))
            } catch {
                print("Something went wrong when writing prospects to disk.")
            }
        }
    }
    
    func toggleContacted(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
