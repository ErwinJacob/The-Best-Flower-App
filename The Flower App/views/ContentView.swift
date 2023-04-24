//
//  ContentView.swift
//  The Flower App
//
//  Created by Jakub Górka on 25/03/2023.
//

import SwiftUI

struct ContentView: View {
//
    @ObservedObject var user: UserData = UserData()
    @State var viewController: String = "login"
    @ObservedObject var view: ViewController = ViewController()
    
    var body: some View {
        
        switch view.view{
        case Views.loginView:
            Login_Page(user: user, view: view)
        case Views.cameraView:
            CameraView(view: view, user: user, flowerId: "XXX")
        case Views.menuView:
            MenuView(user: user, view: view)
        case Views.flowersView:
            FlowersView(user: user)
        default:
            VStack{
                Text("Błąd view controllera")
                    .bold()
            }
        }
    }
}
