//
//  MeView.swift
//  HotProspects
//
//  Created by Dante Cesa on 2/21/22.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var qrCode: UIImage = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
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
                updateQRCode()
            }
            .onChange(of: name) { _ in
                updateQRCode()
            }
            .onChange(of: email) { _ in
                updateQRCode()
            }
        }
    }
    
    func updateQRCode() {
        qrCode = generateQRCodeImage(from: "\(name)\n\(email)")
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
