//
//  FlowerModel.swift
//  The Flower App
//
//  Created by Jakub Górka on 19/04/2023.
//

import Foundation
import SwiftUI
import Firebase

class Flower: Identifiable, ObservableObject{
    //
    @Published var data: [FlowerData] = []
    @Published var flowerId: String
    
    //profilowe(?) dane
    @Published var image: UIImage
    @Published var name: String
    @Published var species: String
    @Published var info: String
    @Published var dominantColor: String
    
    init(imageBlob: String, info: String, flowerId: String, userId: String, name: String, species: String, dominantColor: String){
        
        self.image = convertBase64StringToImage(imageBase64String: imageBlob)
        self.info = info
        self.flowerId = flowerId
        self.name = name
        self.species = species
        self.dominantColor = dominantColor
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
                return FlowerData(imageBlob: d["image"] as? String ?? "", data: d["flowerData"] as? String ?? "", dataId: d.documentID, date: d["date"] as? String ?? "")
            })
            
            return true
        }
        catch{
            self.data = []
            return false
        }
    }
    
    func addFlowerData(){
        
    }
    
    func delFlowerData(){
        
    }
    
}

class FlowerData: Identifiable, ObservableObject{
    
    @Published var image: Image
    //jakies dane ktore wyciagniemy ze zdjecia
    @Published var data: String
    @Published var dataId: String
    @Published var date: String
    
    init(imageBlob: String, data: String, dataId: String, date: String){
        if imageBlob != ""{
            self.image = Image(uiImage: convertBase64StringToImage(imageBase64String: imageBlob))
        }
        else{
            self.image = Image(systemName: "tree.fill")
        }
        self.data = data
        self.dataId = dataId
        self.date = date
    }
    
    
}
