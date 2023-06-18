//import CoreML
//import Vision
//import SwiftUI
//
//func calcPlantSize(){
//    
//    var plantSize: CGFloat = 0
//    var markerSize: CGFloat = 0
//    
//    detections.forEach { detection in
//        let identifier = detection.labels[0].identifier
//        if identifier == "marker"{
//            markerSize = detection.boundingBox.size.height
//        }
//        else if identifier == "monstera"{
//            plantSize = detection.boundingBox.size.height
//        }
//    }
//    
//    print(markerSize)
//    print(plantSize * 3.0/markerSize)
//}
//
//func updateDetections(for image: UIImage) {
////        guard let orientation = CGImagePropertyOrientation(image.imageOrientation) else {
////            return
////        }
//    
//    guard let ciImage = CIImage(image: image) else {
//        return
//    }
//    
//    DispatchQueue.global(qos: .userInitiated).async {
//        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: convertImageOrientation(image.imageOrientation))
//        do {
//            let model = try VNCoreMLModel(for: plant1040().model)
//            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
//                self.processDetections(for: request, error: error)
//            })
//            request.imageCropAndScaleOption = .scaleFit
//            try handler.perform([request])
//        } catch {
//            print("Failed to perform detection.\n\(error.localizedDescription)")
//        }
//    }
//}
//
//func processDetections(for request: VNRequest, error: Error?) {
//    DispatchQueue.main.async {
//        guard let results = request.results as? [VNRecognizedObjectObservation] else {
//            print("Unable to detect anything.\n\(error?.localizedDescription ?? "")")
//            return
//        }
//        
//        self.detections = results
//        
//        calcPlantSize()
//        print(detections.debugDescription)
//        print("\n")
//    }
//}
//
//@ViewBuilder
//private func detectionOverlay(width: CGFloat, height: CGFloat) -> some View {
//    ForEach(detections, id: \.self) { detection in
//        let boundingBox = detection.boundingBox
//        
//        
//        Rectangle()
//            .fill(getRandomColor().opacity(0.4))
//            .frame(width: boundingBox.width * width, height: boundingBox.height * image!.size.height)
//            .position(x: boundingBox.midX * width, y: (height*boundingBox.height*0.5)+boundingBox.midY)
//    }
//}
//
//func getRandomColor() -> Color{
//    let red = Double.random(in: 0...1)
//    let green = Double.random(in: 0...1)
//    let blue = Double.random(in: 0...1)
//    return Color(red: red, green: green, blue: blue)
//}
//func convertImageOrientation(_ imageOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
//    switch imageOrientation {
//    case .up: return .up
//    case .down: return .down
//    case .left: return .left
//    case .right: return .right
//    case .upMirrored: return .upMirrored
//    case .downMirrored: return .downMirrored
//    case .leftMirrored: return .leftMirrored
//    case .rightMirrored: return .rightMirrored
//    @unknown default: return .up
//    }
//}
