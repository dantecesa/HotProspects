//
//  MeView.swift
//  HotProspects
//
//  Created by Dante Cesa on 2/21/22.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @State private var currentUser: CurrentUser = CurrentUser()
    @State private var qrCode: UIImage = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Name", text: $currentUser.name)
                        .textContentType(.name)
                    TextField("Email", text: $currentUser.email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                .disableAutocorrection(true)
                
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding()
                    .padding(.bottom, 100)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label: {
                            Label("Save Image", systemImage: "square.and.arrow.down")
                        }
                    }
            }
            .navigationTitle("My QR Code")
            .onAppear {
                loadUser()
                updateQRCode()
            }
            .onChange(of: currentUser.name) { _ in
                updateQRCode()
                saveUser()
            }
            .onChange(of: currentUser.email) { _ in
                updateQRCode()
                saveUser()
            }
        }
    }
    
    func updateQRCode() {
        qrCode = generateQRCodeImage(from: "\(currentUser.name)\n\(currentUser.email)")
    }
    
    func loadUser() {
        if let data = UserDefaults.standard.data(forKey: "CurrentUser") {
            if let decodedUser = try? JSONDecoder().decode(CurrentUser.self, from: data) {
                self.currentUser = decodedUser
                return
            }
        }
        
        self.currentUser = CurrentUser()
    }
    
    func saveUser() {
        if let encodedUser = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encodedUser, forKey: "CurrentUser")
        }
    }
    
    func generateQRCodeImage(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
