//
//  CameraView.swift
//  The Flower App
//
//  Created by Jakub Górka on 31/03/2023.
//

import SwiftUI
import Firebase
import CoreML
import Vision

struct CameraView: View {
    
    @StateObject var camera: CameraModel = CameraModel()
//    @State var user: UserData
    @ObservedObject var flower: Flower
    
    @State private var isLoading: Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    //coreml
    @State private var detections: [VNRecognizedObjectObservation] = []
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader{ proxy in
            ZStack{
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all)

            if camera.isTaken{
                    VStack{
                        Spacer()
                        HStack{
                            
                            ZStack{
                            }
                            .frame(width: proxy.size.width*0.15, height: proxy.size.width*0.15)

                            
                            Button {
                                //zapisz
                                if !camera.isSaved{
                                    isLoading = true
                                    let cameraImg = camera.savePic() //get image
                                    self.image = cameraImg
                                    
                                    
//                                    coreml
//                                    updateDetections(for: image!)
                                    
                                    let cameraString = convertImageToBase64String(img: cameraImg)

                                    let newEntryId = UUID().uuidString //generate uuid
                                    
                                    let now = Date()
                                    let dtFormatter = DateFormatter()
                                    dtFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                                    let newEntryDate = dtFormatter.string(from: now) //get current date
                                    
                                    let newFlower = FlowerData(imageBlob: cameraString, data: "", entryId: newEntryId, date: newEntryDate, flowerId: flower.flowerId) //create new flowerData object
                                    
                                    Task{
                                        if await flower.addFlowerData(newFlower){
                                            flower.data.append(newFlower)
                                            isLoading = false
                                            print("new FlowerData")
                                            //back to previous view(flower view)
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                        else{
                                            //error
                                            isLoading = false
                                        }
                                    }
                                    
                                    
                                }
                                
                            } label: {
                                ZStack{
                                    Capsule()//.stroke(.white, lineWidth: 3)
                                        .frame(width: proxy.size.width*0.35, height: proxy.size.width*0.15)
                                        .foregroundColor(.white.opacity(0.25))
                                        .overlay {
                                            Capsule().stroke(.white, lineWidth: 3)
                                        }
                                    if isLoading{
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(width: proxy.size.width*0.1, height: proxy.size.width*0.1)
                                    }
                                    else{
                                        Text(camera.isSaved ? "Zapisano" : "Zapisz zdjęcie")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, proxy.size.width*0.05)
                            
                            
                            //retake
                            Button {
                                //cyk fota
                                camera.reTake()
                            } label: {
                                ZStack{
                                    Circle()//.stroke(.white, lineWidth: 3)
                                        .frame(width: proxy.size.width*0.15, height: proxy.size.width*0.15)
                                        .foregroundColor(.white.opacity(0.25))
                                        .overlay {
                                            Circle().stroke(.white, lineWidth: 3)
                                        }
                                    Image(systemName: "camera.rotate")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                    }
                    .overlay(detectionOverlay(width: proxy.size.width, height: proxy.size.height))
                }
            
            else{   
                    VStack{
                        HStack{
                            Spacer()
                        }
                        
                        Spacer()
                        
                        Text("Zrób zdjęcie tak, aby znacznik\n znajdował się w polu ponizej")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .bold()
                        
                        Spacer()
                        
                        ZStack{}
                            .frame(width: proxy.size.width*0.25, height: proxy.size.width*0.25)
                            .overlay{
                                Rectangle().stroke(.white, lineWidth: 2)
                            }
                            .padding(.bottom, 30)
                        
                        Button {
                            //cyk fota
                            camera.takePic{ img in
                                updateDetections(for: img)
                            }
                                
                            
                        } label: {
                            ZStack{
                                Circle()//.stroke(.white, lineWidth: 3)
                                    .frame(width: proxy.size.width*0.15)
                                    .foregroundColor(.white.opacity(0.25))
                                    .overlay {
                                        Circle().stroke(.white, lineWidth: 3)
                                    }
                            }
                        }
                        
                        
                        
                    }
                }
            }
        }
        .onAppear(perform: {
            camera.checkPerm()
        })
        .navigationBarBackButtonHidden(isLoading)
    }
        
    private func calcPlantSize(){
        
        var plantSize: CGFloat = 0
        var markerSize: CGFloat = 0
        
        detections.forEach { detection in
            let identifier = detection.labels[0].identifier
            if identifier == "marker"{
                markerSize = detection.boundingBox.size.height
            }
            else if identifier == "monstera"{
                plantSize = detection.boundingBox.size.height
            }
        }
        
        print(markerSize)
        print(plantSize * 3.0/markerSize)
    }
    
    private func updateDetections(for image: UIImage) {
        
        guard let ciImage = CIImage(image: image) else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: convertImageOrientation(image.imageOrientation))
            do {
                let model = try VNCoreMLModel(for: plant1040().model)
                let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                    self.processDetections(for: request, error: error)
                })
                request.imageCropAndScaleOption = .scaleFit
                try handler.perform([request])
            } catch {
                print("Failed to perform detection.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func processDetections(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                print("Unable to detect anything.\n\(error?.localizedDescription ?? "")")
                return
            }
            
            self.detections = results
            
            calcPlantSize()
            print(detections.debugDescription)
            print("\n")
            
            
        }
    }
    
    @ViewBuilder
    private func detectionOverlay(width: CGFloat, height: CGFloat) -> some View {
        ForEach(detections, id: \.self) { detection in
            let boundingBox = detection.boundingBox
            
            let rect = CGRect(x: boundingBox.minX * width,
                              y: (1 - boundingBox.minY) * height,
                              width: boundingBox.width * width,
                              height: boundingBox.height * height)
            
            Rectangle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX + (width / 2), y: rect.midY + (height / 2))
        }
    }



    
    func getRandomColor() -> Color{
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }
    func convertImageOrientation(_ imageOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
    
}
