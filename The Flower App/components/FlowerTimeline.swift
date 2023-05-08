//
//  FlowerTimeline.swift
//  The Best Flower App
//
//  Created by Jakub Górka on 26/04/2023.
//

import SwiftUI

struct FlowerTimeline: View {
    
    @ObservedObject var flower: Flower
    @State private var deleteConfirm: Bool = false
    var body: some View {
        GeometryReader{ proxy in
            
            ScrollView(.horizontal){
                HStack(){
                    
                    NavigationLink(destination: CameraView(flower: self.flower)) {
                        VStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.primary).opacity(0.05)
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: proxy.size.width*0.15)
                                    .foregroundColor(.blue)
                            }
                            .frame(width: proxy.size.width*0.4, height: proxy.size.height*0.8)
                            Text("Add photo")
                                .font(.footnote)
                        }
                    }
                    
//                    ForEach(flower.data) { flowerData in
                    ForEach(Array(flower.data.enumerated()), id: \.element) { index, flowerData in
                        VStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.primary).opacity(0.05)
                                Image(uiImage: flowerData.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: proxy.size.width*0.3)
                                VStack {
                                    HStack{
                                        Spacer()
                                        Button {
                                            deleteConfirm = true
                                        } label: {
                                            Image(systemName: "trash.circle.fill")
                                                .resizable()
                                                .foregroundColor(.red)
                                                .scaledToFit()
                                                .frame(width: proxy.size.width*0.06)
                                                .padding(.top, proxy.size.width*0.01)
                                                .padding(.trailing, proxy.size.width*0.01)
                                        }
                                        .confirmationDialog("Are you sure?",
                                          isPresented: $deleteConfirm) {
                                          Button("Delete this entry", role: .destructive) {
                                              Task{
                                                  if await flower.delFlowerData(flowerDataToDelete: flowerData){
                                                      //TODO: usuniecie z tablicy
                                                      deleteConfirm = false
                                                      flower.data.remove(at: index)
                                                  }
                                                  else{
                                                      //error
                                                      deleteConfirm = false
                                                  }
                                              }
                                           }
                                         }

                                        
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: proxy.size.width*0.4, height: proxy.size.height*0.8)
                            
                            Text(flowerData.date)
                                .font(.footnote)
                        }
//                        .onLongPressGesture {
//                            Task{
//                                if await flower.delFlowerData(flowerDataToDelete: flowerData){
//                                    //TODO: usuniecie z tablicy
//                                }
//                                else{
//                                    //error
//                                }
//                            }
//                        }
                    }
                }
                .padding(.bottom, proxy.size.height*0.05)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            
        }
    }
}

