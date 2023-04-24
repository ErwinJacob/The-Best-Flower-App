//
//  MenuView.swift
//  The Flower App
//
//  Created by Jakub Górka on 18/04/2023.
//

import SwiftUI

struct MenuView: View {
    
    @ObservedObject var user: UserData
    @ObservedObject var view: ViewController
    //
    var body: some View {
        VStack{
            
            Text("User id: \n" + user.data!.uid)
            
            
            Button {
                view.changeView(newView: Views.cameraView)
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 40)
                        .foregroundColor(.green)
                    Text("Kamera")
                        .foregroundColor(.white)
                }
            }
            
            Button {
                view.changeView(newView: Views.flowersView)
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 40)
                        .foregroundColor(.green)
                    Text("Flowers")
                        .foregroundColor(.white)
                }
            }
            
            Button {
                user.logout()
                view.changeView(newView: Views.loginView)
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 40)
                        .foregroundColor(.green)
                    Text("Logout")
                        .foregroundColor(.white)
                }
            }

        }
    }
}


