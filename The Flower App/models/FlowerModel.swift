//
//  FlowerModel.swift
//  The Flower App
//
//  Created by Jakub Górka on 19/04/2023.
//

import Foundation
import SwiftUI
import Firebase

class Flower: Identifiable, ObservableObject, Hashable{
    static func == (lhs: Flower, rhs: Flower) -> Bool {
        if lhs.id == rhs.id {return true}
        else{return false}
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    //
    @Published var data: [FlowerData] = []
    @Published var flowerId: String
    @Published var userId: String
    @Published var date: String
    
    //profilowe(?) dane
    @Published var image: UIImage
    @Published var name: String
    @Published var species: String
    @Published var info: String
    @Published var dominantColor: String
    
    init(){
        self.flowerId = ""
        self.userId = ""
        self.image = UIImage(systemName: "pencil")!
        self.name = ""
        self.species = ""
        self.info = ""
        self.dominantColor = ""
        self.date = ""
    }
    
    init(imageBlob: String, info: String, flowerId: String, userId: String, name: String, species: String, dominantColor: String, date: String){
        
        self.userId = userId
        
        self.image = convertBase64StringToImage(imageBase64String: imageBlob)
        self.info = info
        self.flowerId = flowerId
        self.name = name
        self.species = species
        self.dominantColor = dominantColor
        self.date = date
        Task{
            await self.fetchFlowerData(userId: userId)
        }
    }
        
    func getImageBlob() -> String{
        return convertImageToBase64String(img: self.image)
    }
    
    func fetchFlowerData(userId: String) async -> Bool{
        
        do{
            let db = Firestore.firestore()
            let snapshot = try await db.collection("Users").document(userId).collection("Flowers").document(flowerId).collection("Data").getDocuments()
            self.data = snapshot.documents.map({ d in
                return FlowerData(imageBlob: d["image"] as? String ?? "", data: d["flowerData"] as? String ?? "", entryId: d.documentID, date: d["date"] as? String ?? "", flowerId: self.flowerId)
            })
            
            return true
        }
        catch{
            self.data = []
            return false
        }
    }
    
    func addFlowerData(_ newFlowerData: FlowerData) async -> Bool{
        
        do{
            let db = Firestore.firestore()
            
            try await db.collection("Users").document(self.userId).collection("Flowers").document(self.flowerId).collection("Data").document(newFlowerData.entryId).setData([
                "data": newFlowerData.data,
                "date": newFlowerData.date,
                "image": newFlowerData.getImageBlob()
            ])
            
//            self.data.append(newFlowerData) //append done inside button to get view update
            
            return true
        }
        catch{
            return false
        }
        
    }
    
    func delFlowerData(flowerDataToDelete: FlowerData) async -> Bool{
        
        do{
            let db = Firestore.firestore()
            
            try await db.collection("Users").document(self.userId).collection("Flowers").document(self.flowerId).collection("Data").document(flowerDataToDelete.entryId).delete()
                        
            return true
        }
        catch{
            return false
        }
        
    }
    
}

//struct ImageData{
//    
//    let label: String
//    
//    
//}

class FlowerData: Identifiable, ObservableObject, Hashable{
    
    static func == (lhs: FlowerData, rhs: FlowerData) -> Bool {
        if lhs.entryId == rhs.entryId {return true}
        else{return false}
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.entryId)
    }

    
    @Published var image: UIImage
    //jakies dane ktore wyciagniemy ze zdjecia
    @Published var data: String
    @Published var entryId: String
    @Published var date: String
    @Published var flowerId: String
    
//    @Published var imageData: [ImageData] = [] //TODO: dodac do firebase
    
    
    init(imageBlob: String, data: String, entryId: String, date: String, flowerId: String){
        if imageBlob != ""{
            self.image = convertBase64StringToImage(imageBase64String: imageBlob)
        }
        else{
            self.image = UIImage(systemName: "tree.fill")!
        }
        self.data = data
        self.entryId = entryId
        self.date = date
        self.flowerId = flowerId
    }
    
    func getImageBlob() -> String{
        return convertImageToBase64String(img: self.image)
    }
    
}
