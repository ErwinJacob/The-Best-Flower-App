//
//  FlowersView.swift
//  The Flower App
//
//  Created by Jakub Górka on 19/04/2023.
//

import SwiftUI

struct FlowerTile: View {
    var name: String
    var species: String
    var description: String
    var photo: UIImage
    
    var body: some View {
        HStack{
            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .padding(.trailing, 10)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(species)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
    }
}

struct FlowersView: View {
    
    @ObservedObject var user: UserData
    @State var showingEditAlert: Bool = false
    @State private var editorFlowerName: String = ""
    @State private var selectedFlower: Flower = Flower()
    
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
                            let newFlower: Flower = Flower(imageBlob: convertImageToBase64String(img: UIImage(named: "test")!), info: "no info", flowerId: newFlowerId, userId: user.data!.uid, name: "no name", species: "no species", dominantColor: "#000000")
                            Task{
                                if (await user.addFlower(newFlower: newFlower)) {
                                    user.flowers.append(newFlower) // append the new flower to the user.flowers array
                                }
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
                    
                    List{
                        ForEach(user.flowers, id: \.self) { flower in
                            NavigationLink {
                                FlowerView(flower: flower)
                            } label: {
                                FlowerTile(name: flower.name, species: "species", description: "description", photo: flower.image)
                            }
                            .swipeActions(allowsFullSwipe: true) {
                                Button(role: .destructive, action: {
                                    Task{
                                        await user.delFlower(delFlower: flower)
                                    }
                                } ) {
                                        Label("Delete", systemImage: "trash")
                                }
                                Button (action: {
                                    editorFlowerName = flower.name
                                    selectedFlower = flower
                                    showingEditAlert.toggle()
                                }) {
                                  Label("Modify", systemImage: "pencil")
                                }
                                .tint(Color(UIColor.systemBlue))
                            }
                        }
                    }
                    .refreshable {
                        await user.fetchData()
                    }
                    .alert("Enter new flower name", isPresented: $showingEditAlert) {
                        TextField("Enter your name", text: $editorFlowerName)
                        Button("OK", action: {
                            selectedFlower.name = editorFlowerName
                            Task{
                                await user.modifyFlower(modFlower: selectedFlower)
                            }
                        }
                        )
                        Button("Cancel", role: .cancel, action: {})
                    }

                    
                }
            }
        }
    }
    
    
}
