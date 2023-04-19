//
//  ViewController.swift
//  The Flower App
//
//  Created by Jakub Górka on 18/04/2023.
//

import Foundation

enum Views {
case loginView
case cameraView
case menuView
case flowersView
}

class ViewController : Identifiable, ObservableObject{
    
    @Published var view: Views = Views.loginView
    
    @MainActor
    func changeView(newView: Views){
        self.view = newView
    }
}
