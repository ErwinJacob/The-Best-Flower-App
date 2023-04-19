//
//  CameraModel.swift
//  The Flower App
//
//  Created by Jakub Górka on 31/03/2023.
//

import Foundation
import SwiftUI
import AVFoundation


class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate{
    @Published var isTaken: Bool = false
    @Published var session = AVCaptureSession()
    @Published var alert: Bool = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    @Published var isSaved: Bool = false
    @Published var picData = Data(count: 0)
    func checkPerm(){
        
        //check if app has camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            //setting up session
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status{
                    self.setUp()
                }
            }
            return
        case .denied:
            self.alert.toggle()
        default:
            return
        }
    }
    
    func setUp(){
        
        
        do{
            self.session.beginConfiguration()
            
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(output){
                self.session.addOutput(output)
            }
            
            self.session.commitConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
            
    }
    
    func takePic(){
        DispatchQueue.global(qos: .background).async{
            
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.session.stopRunning()
            })
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    
    func reTake(){
        DispatchQueue.global(qos: .background).async{
            self.session.startRunning()
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                
                self.isSaved = false
            }

        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if error != nil{
            return
        }
        
        print("photo taken :)")
        
        guard let imageData = photo.fileDataRepresentation() else {return}
        
        self.picData = imageData
    }
    
    func savePic() -> String{
        let image = UIImage(data: self.picData)!
        
        //TODO: Zapisywanie do bazy danych
        let stringImg = convertImageToBase64String(img: image)
        
        //Saving image to iOS photo gallery
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        print("saved successfully")
        self.isSaved = true
        
        return stringImg
    }
    
}



func convertImageToBase64String (img: UIImage) -> String {
    return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
}

func convertBase64StringToImage (imageBase64String:String) -> UIImage {
    let imageData = Data(base64Encoded: imageBase64String)
    let image = UIImage(data: imageData!)
    return image!
}


struct CameraPreview: UIViewRepresentable{
    
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        //proparties
        camera.preview.videoGravity = .resizeAspectFill 
        
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}


