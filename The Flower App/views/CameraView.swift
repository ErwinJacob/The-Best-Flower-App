import SwiftUI
import Firebase
import CoreML
import Vision

struct CameraView: View {

    @StateObject var camera: CameraModel = CameraModel()
    @ObservedObject var flower: Flower
    
    @State private var isLoading: Bool = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var detections: [VNRecognizedObjectObservation] = []
    @State private var image: UIImage?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all)
                    .overlay {
                        if camera.isTaken{
                            detectionOverlay(proxy: proxy)
                        }
                    }

                if camera.isTaken {
                    VStack {
                        Spacer()
                        HStack {

                            ZStack {
                                // Additional views or overlays
                            }
                            .frame(width: proxy.size.width * 0.15, height: proxy.size.width * 0.15)

                            Button {
                                // Save button action
                                if !camera.isSaved {
                                    isLoading = true
                                    let cameraImg = camera.savePic() // Get image
                                    self.image = cameraImg

                                    let cameraString = convertImageToBase64String(img: cameraImg)

                                    let newEntryId = UUID().uuidString
                                    let now = Date()
                                    let dtFormatter = DateFormatter()
                                    dtFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                                    let newEntryDate = dtFormatter.string(from: now)

                                    let newHeight = Int(calcPlantSize())
                                    
                                    if Int(self.flower.info) ?? 0<newHeight{
                                        self.flower.info = String(newHeight)
                                    }
                                    if flower.species == "Not known"{
                                        self.flower.species = detectPlantSpecies()
                                    }
                                    
                                    let newFlower = FlowerData(imageBlob: cameraString, data: "", entryId: newEntryId, date: newEntryDate, flowerId: flower.flowerId, height: String(newHeight))

                                    Task {
                                        if await flower.addFlowerData(newFlower) {
                                            flower.data.append(newFlower)
                                            isLoading = false
                                            print("New FlowerData")
                                            await flower.modifyFlower()
                                            presentationMode.wrappedValue.dismiss()
                                        } else {
                                            isLoading = false
                                            // Handle error
                                        }
                                    }
                                }
                            } label: {
                                ZStack {
                                    Capsule()
                                        .frame(width: proxy.size.width * 0.35, height: proxy.size.width * 0.15)
                                        .foregroundColor(.white.opacity(0.25))
                                        .overlay {
                                            Capsule().stroke(.white, lineWidth: 3)
                                        }
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(width: proxy.size.width * 0.1, height: proxy.size.width * 0.1)
                                    } else {
                                        Text(camera.isSaved ? "Zapisano" : "Zapisz zdjęcie")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, proxy.size.width * 0.05)

                            // Retake button
                            Button {
                                camera.reTake()

                            } label: {
                                ZStack {
                                    Circle()
                                        .frame(width: proxy.size.width * 0.15, height: proxy.size.width * 0.15)
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
                } else {
                    VStack {
                        HStack {
                            Spacer()
                        }

                        Spacer()

                        Text("Zrób zdjęcie tak, aby znacznik\nznajdował się w polu poniżej")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .bold()

                        Spacer()

                        ZStack {
                            // Additional views or overlays
                        }
                        .frame(width: proxy.size.width * 0.25, height: proxy.size.width * 0.25)
                        .overlay {
                            Rectangle().stroke(.white, lineWidth: 2)
                        }
                        .padding(.bottom, 30)

                        Button {
                            camera.takePic { img in
                                updateDetections(for: img)
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: proxy.size.width * 0.15)
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

    @ViewBuilder
    private func detectionOverlay(proxy: GeometryProxy) -> some View {
        ForEach(detections, id: \.self) { detection in
            let boundingBox = detection.boundingBox

            Rectangle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: boundingBox.width * proxy.size.width,
                       height: boundingBox.height * proxy.size.height)
                .position(x: boundingBox.midX * proxy.size.width,
                          y: (1 - boundingBox.midY) * proxy.size.height)
        }
    }


    private func updateDetections(for image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: convertImageOrientation(image.imageOrientation))
            do {
                let model = try VNCoreMLModel(for: newPlantModel450().model)
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

//            calcPlantSize()
            print(detections.debugDescription)
            print("\n")
        }
    }

    private func detectPlantSpecies() -> String{
        
        var species = "Not known"
        detections.forEach { detection in
            
            if detection.labels[0].identifier == "monstera"{
                species =  "Monstera Deliciosa"
            }
        }
        
        print("Species \(species)")
        return species
    }
    
    private func calcPlantSize() -> Float{
        var plantSize: CGFloat = 0
        var markerSize: CGFloat = 0

        detections.forEach { detection in
            let identifier = detection.labels[0].identifier
            if identifier == "marker" {
                markerSize = detection.boundingBox.size.height
            } else if identifier == "monstera" {
                plantSize = detection.boundingBox.size.height
            }
        }

        print(markerSize)

        if plantSize.isNormal || markerSize.isNormal{
            return Float(plantSize * 3.0 / markerSize)
        }
        else{
            return 0.0
        }
    }

    private func convertImageOrientation(_ imageOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
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
