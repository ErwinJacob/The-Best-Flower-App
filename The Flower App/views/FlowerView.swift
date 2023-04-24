//
//  FlowerView.swift
//  The Flower App
//
//  Created by Jakub Górka on 19/04/2023.
//

import SwiftUI

struct FlowerView: View {
    
    //
    @State var flower: Flower
    
    var body: some View {
        GeometryReader{ proxy in
            
            VStack{
                HStack{
                    
                    Spacer()
                    
                    Text("Flower: ")
                        .bold()
                        .font(.title)
                    
                    Text(flower.name)
                        .font(.title2)
                    
                    Spacer()
                }
                
                HStack{
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
                            Text(flower.growth)
                        }
                        HStack{
                            Text("Stan: ")
                                .bold()
                                .font(.title3)
                            Spacer()
                            Text(flower.health)
                        }
                    }
                    .frame(width: proxy.size.width*0.5 , height: proxy.size.height*0.2)
                    .padding(.horizontal, proxy.size.width*0.025)
                    Image(uiImage: flower.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: proxy.size.height*0.2)
                    
                }
                .frame(height: proxy.size.height*0.2)
                .padding(.vertical, proxy.size.width*0.05)
                .padding(.top, proxy.size.height*0.05)
                
                Spacer()
                
                Text("Timeline")
                    .bold()
                    .font(.title)
                ScrollView(.horizontal){
                    HStack{
                        ForEach(flower.data) { flowerData in
                            VStack{
                                Text(flowerData.date)
//                                Text(flowerData.dataId)
//                                Image(uiImage: flowerData.image)
                                
                                flowerData.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: proxy.size.width*0.3)
                            }
                            .frame(width: proxy.size.width*0.35)
                        }
                    }
                }
                .padding(.horizontal, proxy.size.width*0.05)
                
                Spacer()
                
            }
        }
    }
}


