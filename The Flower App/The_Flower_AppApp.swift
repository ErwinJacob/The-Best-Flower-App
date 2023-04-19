//
//  The_Flower_AppApp.swift
//  The Flower App
//
//  Created by Jakub Górka on 25/03/2023.
//

import SwiftUI
import Firebase

@main
struct The_Flower_AppApp: App {
    
    init(){
        FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
