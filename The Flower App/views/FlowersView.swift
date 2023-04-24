//
//  FlowersView.swift
//  The Flower App
//
//  Created by Jakub Górka on 19/04/2023.
//

import SwiftUI

struct FlowersView: View {
    
    //
    @ObservedObject var user: UserData
    
    var body: some View {
        GeometryReader{ proxy in
            NavigationView {
                VStack{
                    HStack{
                        VStack{
                            
                        }
                        .frame(width: proxy.size.width*0.075, height: proxy.size.width*0.075)
                        .padding(.leading, proxy.size.width*0.05)
                        
                        Spacer()
                        
                        Text("Flowers")
                            .bold()
                            .font(.title)
                        
                        Spacer()
                        
                        Button {
                            //add
                            let newFlowerId = UUID().uuidString
                            let newFlower: Flower = Flower(imageBlob: convertImageToBase64String(img: UIImage(named: "test")!), informacje: "", flowerId: newFlowerId, userId: user.data!.uid, name: "", species: "", growth: "", health: "")
                            Task{
                                await user.addFlower(newFlower: newFlower)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: proxy.size.width*0.075, height: proxy.size.width*0.075)
                                .foregroundColor(.green)
                        }
                        .padding(.trailing, proxy.size.width*0.05)
                        
                    }
                    
                    Spacer()
                    ScrollView{
                        ForEach(user.flowers) { flower in
                            NavigationLink {
                                FlowerView(flower: flower)
                            } label: {
                                HStack{
                                    VStack(alignment: .center){
                                        HStack{
                                            Spacer()
                                            Text(flower.name)
                                                .bold()
                                                .foregroundColor(Color(UIColor.label))
                                                .font(.title2)
                                            Spacer()
                                        }
//                                        Text(flower.informacje)
                                        //dane - gatunek wzrost zdrowie kiedy ostatnio zrobione zdjecie kiedy ostatnio podlane
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    Image(uiImage: flower.image)
                                        .resizable()
                                        .frame(width: proxy.size.height*0.2, height: proxy.size.height*0.2)
                                    //Image(uiImage: img)
                                }
                            }
                            .padding(.horizontal, proxy.size.width*0.05)
                            
                        }
                    }
                    .padding(.vertical, proxy.size.width*0.05)
                }
            }
        }
    }
}
