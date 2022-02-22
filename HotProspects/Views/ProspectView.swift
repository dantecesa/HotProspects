//
//  ProspectView.swift
//  HotProspects
//
//  Created by Dante Cesa on 2/21/22.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortType {
        case name, email, dateAdded
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var showQRScanSheet: Bool = false
    var filter: FilterType
    @State var sort: SortType = .name
        
    var body: some View {
        NavigationView {
            List {
                ForEach(
                    filteredProspects.sorted(by: {
                        switch sort {
                        case .name:
                            return $0.name < $1.name
                        case .email:
                            return $0.email < $1.email
                        case .dateAdded:
                            return $0.dateAdded < $1.dateAdded
                        }
                    })) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if prospect.isContacted && filter == .none {
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions {
                        Button {
                            withAnimation {
                                prospects.delete(prospect)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        
                        if prospect.isContacted {
                            Button {
                                withAnimation {
                                    prospects.toggleContacted(prospect)
                                }
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                withAnimation {
                                    addNotifications(for: prospect)
                                }
                            } label: {
                                Label("Remind me", systemImage: "bell")
                            }
                            .tint(.orange)
                            
                            Button {
                                withAnimation {
                                    prospects.toggleContacted(prospect)
                                }
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu(content: {
                        Button(action: {
                            sort = .name
                        }, label: {
                            if sort == .name {
                                HStack {
                                    Text("By Name…")
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            } else {
                                Text("By Name…")
                            }
                        })
                        Button(action: {
                            sort = .email
                        }, label: {
                            if sort == .email {
                                HStack {
                                    Text("By Email…")
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            } else {
                                Text("By Email…")
                            }
                        })
                        Button(action: {
                            sort = .dateAdded
                        }, label: {
                            if sort == .dateAdded {
                                HStack {
                                    Text("By Date Added…")
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            } else {
                                Text("By Date Added…")
                            }
                        })
                    }, label: {
                        Text("Sort…")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showQRScanSheet = true
                    } label: {
                        Label("Scan Prospect", systemImage: "qrcode.viewfinder")
                    }
                }
                /*ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let person1 = Prospect()
                        person1.name = "A"
                        person1.email = "zazzle@z.com"
                        
                        let person2 = Prospect()
                        person2.name = "Z"
                        person2.email = "dante@test.com"
                        
                        prospects.add(person1)
                        prospects.add(person2)
                    } label: {
                        Text("Add Tests")
                    }
                }*/
            }
            .sheet(isPresented: $showQRScanSheet) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
            }
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted"
        case .uncontacted:
            return "Uncontacted"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    func addNotifications(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.email
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("Doh!")
                    }
                }
            }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        showQRScanSheet = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.email = details[1]
            
            prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed. \(error.localizedDescription)")
        }
    }
}

struct ProspectView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectView(filter: .none)
    }
}
