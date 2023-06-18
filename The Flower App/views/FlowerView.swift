//
//  FlowerView.swift
//  The Flower App
//
//  Created by Jakub Górka on 19/04/2023.
//

import SwiftUI

struct FlowerView: View {
    
    @ObservedObject var flower: Flower
    @State private var showChangeImageView: Bool = false
    
    var body: some View {
        GeometryReader{ proxy in
            
            VStack{
                HStack{

                    Spacer()

                    Text("Flower: ")
                        .bold()
                        .font(.title2)

                    Text(flower.name)
                        .font(.title2)

                    Spacer()
                }

                Spacer()
                
                if showChangeImageView{
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(flower.data){ flowerData in
                                Button {
                                    flower.image = flowerData.image
                                    Task{
                                        await flower.modifyFlower()
                                    }
                                    showChangeImageView = false
                                } label: {
//                                    Image(uiImage: flowerData.image)
//                                        .resizable()
//                                        .scaledToFit()
////                                        .frame(width: proxy.size.height*0.25)
//                                        .clipShape(Circle())
                                    Image(uiImage: flowerData.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: proxy.size.height*0.25, height: proxy.size.height*0.25)
                                        .cornerRadius(10)

                                }
                            }
                        }
                    }
                    .frame(width: proxy.size.width*0.9, height: proxy.size.height*0.25)
                }
                else{
                    Button {
                        showChangeImageView = true
                    } label: {
                        Image(uiImage: flower.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.height*0.25, height: proxy.size.height*0.25)
                            .cornerRadius(10)
//                        Image(uiImage: flower.image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: proxy.size.height*0.25)
//                            .clipShape(Circle())

                    }
                }

                Spacer()
                
                VStack{
                    HStack{
                        Text("Gatunek: ")
                            .bold()
                            .font(.title3)
                        Spacer()
                        Text(flower.species)
                    }
                    HStack{
                        Text("Wzrost: ")
                            .bold()
                            .font(.title3)
                        Spacer()
                        Text("\(flower.info) cm")
                    }
                }
                .frame(width: proxy.size.width*0.8)
                .padding(.horizontal, proxy.size.width*0.1)
                .padding(.vertical, proxy.size.height*0.05)

                Spacer()
                
                Text("Timeline")
                    .bold()
                    .font(.title)

                FlowerTimeline(flower: flower)
                    .frame(width: proxy.size.width*0.95, height: proxy.size.height*0.4)
                    .padding(.horizontal, proxy.size.width*0.025)

                                
                
            }
        }
    }
}


