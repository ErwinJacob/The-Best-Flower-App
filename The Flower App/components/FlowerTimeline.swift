//
//  FlowerTimeline.swift
//  The Best Flower App
//
//  Created by Jakub Górka on 26/04/2023.
//

import SwiftUI

struct FlowerTimeline: View {
    
    @ObservedObject var flower: Flower
    
    var body: some View {
        GeometryReader{ proxy in
            
            ScrollView(.horizontal){
                HStack(){
                    
                    NavigationLink(destination: CameraView(flower: self.flower)) {
                        VStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.black).opacity(0.05)
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
                    
                    ForEach(flower.data) { flowerData in
                        VStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.black).opacity(0.05)
                                Image(uiImage: flowerData.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: proxy.size.width*0.3)
                                VStack {
                                    HStack{
                                        Spacer()
                                        Button {
                                            Task{
                                                if await flower.delFlowerData(flowerDataToDelete: flowerData){
                                                    //TODO: usuniecie z tablicy
                                                }
                                                else{
                                                    //error
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "trash.circle.fill")
                                                .resizable()
                                                .foregroundColor(.red)
                                                .scaledToFit()
                                                .frame(width: proxy.size.width*0.06)
                                                .padding(.top, proxy.size.width*0.01)
                                                .padding(.trailing, proxy.size.width*0.01)
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

