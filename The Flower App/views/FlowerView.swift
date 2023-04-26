//
//  FlowerView.swift
//  The Flower App
//
//  Created by Jakub Górka on 19/04/2023.
//

import SwiftUI

struct FlowerView: View {
    
    @ObservedObject var flower: Flower
    
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

                Spacer()
                
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
                            Text("Kolor dominujący: ")
                                .bold()
                                .font(.title3)
                            Spacer()
                            Text(flower.dominantColor)
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


