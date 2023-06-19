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
                if species != "Not known"{
                    Text(species)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
//                Text(description)
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(2)
            }
        }
    }
}

struct FlowersView: View {
    
    @ObservedObject var user: UserData
    @State var showingEditAlert: Bool = false
    @State private var editorFlowerName: String = ""
    @State private var selectedFlower: Flower = Flower()
    @State private var selectedFlowerId: Int = 0
    @ObservedObject var view: ViewController
    @State private var deleteConfirm: Bool = false
    
    var body: some View {
        GeometryReader{ proxy in
            NavigationView {
                VStack{
                    HStack{
                        Button{
                            user.logout()
                            view.changeView(newView: Views.loginView)
                        } label: {
                            ZStack{
                                Circle()
                                    .foregroundColor(.red)
                                    .frame(width: proxy.size.width*0.075, height: proxy.size.width*0.075)
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .resizable()
                                    .frame(width: proxy.size.width*0.045, height: proxy.size.width*0.045)
                                    .foregroundColor(.white)
                                    .padding(.leading, proxy.size.width*0.005)
                            }
                        }
                        .padding(.leading, proxy.size.width*0.05)
                        
                        Spacer()
                        
                        Text("Flowers")
                            .bold()
                            .font(.title)
                        
                        Spacer()
                        
                        Button {
                            //add
                            let newFlowerId = UUID().uuidString // generate uuid
                            
                            let now = Date()
                            let dtFormatter = DateFormatter()
                            dtFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                            let newEntryDate = dtFormatter.string(from: now) //get current date

                            
                            let newFlower: Flower = Flower(imageBlob: convertImageToBase64String(img: UIImage(named: "test")!), info: "0", flowerId: newFlowerId, userId: user.data!.uid, name: "My new flower", species: "Not known", dominantColor: "#000000", date: newEntryDate)
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
                        ForEach(Array(user.flowers.enumerated()), id: \.element) { index, flower in
                            NavigationLink {
                                FlowerView(flower: flower)
                            } label: {
                                FlowerTile(name: flower.name, species: flower.species, description: "description", photo: flower.image)
                            }
                            .swipeActions(allowsFullSwipe: true) {
                                Button(role: .none, action: {
                                    deleteConfirm = true
                                    selectedFlower = flower
                                    selectedFlowerId = index
                                } ) {
                                        Label("Delete", systemImage: "trash")
                                }
                                .tint(Color(UIColor.systemRed))

                                Button (action: {
                                    editorFlowerName = flower.name
                                    selectedFlower = flower
                                    selectedFlowerId = index
                                    showingEditAlert.toggle()
                                }) {
                                  Label("Modify", systemImage: "pencil")
                                }
                                .tint(Color(UIColor.systemBlue))
                            }
                            .confirmationDialog("Are you sure?", isPresented: $deleteConfirm) {
                                Button("Delete flower: \(selectedFlower.name)", role: .destructive) {
                                    Task{
                                        if await user.delFlower(delFlower: selectedFlower){
                                            //TODO: usuniecie z tablicy
                                            deleteConfirm = false
                                            user.flowers.remove(at: selectedFlowerId)
                                        }
                                        else{
                                            //error
                                            deleteConfirm = false
                                        }
                                    }
                                }
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
