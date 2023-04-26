//
//  User.swift
//  The Flower App
//
//  Created by Jakub Górka on 25/03/2023.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

class UserData: Identifiable, ObservableObject{
    @AppStorage("email") var email = ""
    @AppStorage("password") var password = ""
    @AppStorage("isLogged") var isLogged: Bool = false
    @Published var data: User?
    @Published var errorMessage = ""
    @Published var flowers: [Flower] = []
    
    @MainActor
    func addFlower(newFlower: Flower) async -> Bool{
        
//        let newFlowerId = UUID().uuidString
//        let newFlower: Flower = Flower(imageBlob: convertImageToBase64String(img: UIImage(named: "test")!), info: "", flowerId: newFlowerId, userId: self.data!.uid, name: "", species: "", growth: "", health: "")
        
        do{
            let db = Firestore.firestore()
            
            try await db.collection("Users").document(self.data!.uid).collection("Flowers").document(newFlower.flowerId).setData([
                "image": newFlower.getImageBlob(),
                "info": newFlower.info,
                "name": newFlower.name,
                "species": newFlower.species,
                "dominantColor": newFlower.dominantColor
            ])
            
            return true
        }
        catch{
            return false
        }
    }
    
    @MainActor
    func delFlower(delFlower: Flower) async -> Bool{
        do{
            let db = Firestore.firestore()
            
            try await db.collection("Users").document(self.data!.uid).collection("Flowers").document(delFlower.flowerId).delete()
            
            return true
        }
        catch{
            return false
        }
    }
    
    @MainActor
    func modifyFlower(modFlower: Flower) async -> Bool{
        do{
            let db = Firestore.firestore()
            
            try await db.collection("Users").document(self.data!.uid).collection("Flowers").document(modFlower.flowerId).setData([
                "image": modFlower.getImageBlob(),
                "info": modFlower.info,
                "name": modFlower.name,
                "species": modFlower.species,
                "dominantColor": modFlower.dominantColor
            ])
            
            return true
        }
        catch{
            return false
        }
    }
    
    @MainActor
    func fetchData() async -> Bool{
        if self.data == nil{ return false}
        else{
            do{
                let db = Firestore.firestore()
                let snapshot = try await db.collection("Users").document(self.data!.uid).collection("Flowers").getDocuments()
                self.flowers = snapshot.documents.map({ flower in
                    return Flower(imageBlob: flower["image"] as? String ?? "",
                                  info: flower["info"] as? String ?? "info missing",
                                  flowerId: flower.documentID, userId: data!.uid,
                                  name: flower["name"] as? String ?? "name",
                                  species: flower["species"] as? String ?? "species",
                                  dominantColor: flower["dominantColor"] as? String ?? "dominantColor")
                })
                
                return true
            }
            catch{
                self.flowers = []
                return false
            }
        }
    }
    
        
    @MainActor
    func login() async -> Bool{
        
        do{
            let authDataResult = try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            data = authDataResult.user
            self.isLogged = true
            
            await self.fetchData() //!!!!!!!!!!!!!!!!!!!!!!! TODO: test
            
//            print(convertImageToBase64String(img: UIImage(named: "test")!))
            
            
            return true
        }
        catch{
            print("There was an issue when trying to sign in: \(error)")
            self.errorMessage = error.localizedDescription
            return false
        }
        
    }
    
    @MainActor
    func register(confirmPassword: String) async -> Bool{
        if (self.email == "" || self.password == ""){
            self.errorMessage = "Pole nie może być puste"
            return false
        }
        else if (self.password != confirmPassword){
            self.errorMessage = "Hasła nie zgadzają się"
            return false
        }
        else{
                //success
            do{
                let authDataResult = try await Auth.auth().createUser(withEmail: self.email, password: self.password)
                data = authDataResult.user
                self.isLogged = true
                return true
            }
            catch{
                print("There was an issue when trying to register: \(error)")
                self.errorMessage = error.localizedDescription
                return false
            }
            
        }
        
    }
    
    func logout(){
        do{
            try Auth.auth().signOut()
            self.email = ""
            self.password = ""
            self.errorMessage = ""
            self.isLogged = false
        }
        catch{
            print("ERROR - logout")
        }
    }

}

