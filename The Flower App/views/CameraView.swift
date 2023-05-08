//
//  CameraView.swift
//  The Flower App
//
//  Created by Jakub Górka on 31/03/2023.
//

import SwiftUI
import Firebase

struct CameraView: View {
    
    @StateObject var camera: CameraModel = CameraModel()
//    @State var user: UserData
    @ObservedObject var flower: Flower
    
    @State private var isLoading: Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
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
                                //cyk fota
                                if !camera.isSaved{
                                    isLoading = true
                                    let cameraString = camera.savePic() //get image
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
                }
            
            else{   
                    VStack{
                        HStack{
                            Spacer()
//                            Button {
////                                view.changeView(newView: Views.menuView)
//                                presentationMode.wrappedValue.dismiss()
//                            } label: {
//                                ZStack{
//                                    Circle()
//                                        .frame(width: 35, height: 35)
//                                        .foregroundColor(.green)
//                                    Text("<")
//                                        .foregroundColor(.white)
//                                }
//                            }
//                            .padding(.trailing, 20)
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
                            camera.takePic()
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
    }
        
}
