//
//  Login Page.swift
//  The Flower App
//
//  Created by Jakub Górka on 25/03/2023.
//

import SwiftUI

struct Login_Page: View {
    
    @State var isLoginActive: Bool = true
    @State var isRegisterActive: Bool = false
    
    var body: some View {
        GeometryReader{ proxy in
            VStack{
                Spacer()
                    HStack(){
                        Spacer()
                        VStack(alignment: .center){
                            
                            Spacer()
                            
                            HStack(){
                                Button {
                                    isLoginActive = true
                                    isRegisterActive = false
                                } label: {
                                    if isLoginActive{
                                        LoginLabel(text: "Login", textColor: .black)
                                    }
                                    else{
                                        LoginLabel(text: "Login", textColor: .gray)
                                    }
                                }
                                .padding(.trailing, 15)
                                
                                Button {
                                    isLoginActive = false
                                    isRegisterActive = true
                                } label: {
                                    if isRegisterActive{
                                        LoginLabel(text: "Register", textColor: .black)
                                    }
                                    else{
                                        LoginLabel(text: "Register", textColor: .gray)
                                    }
                                }
                                .padding(.leading, 15)


                            }
                            .padding(.bottom, 75)
                            
                            if isLoginActive{
                                ZStack(){
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: proxy.size.width*0.85, height: proxy.size.width*0.85)
                                        .foregroundColor(.black)
                                        .opacity(0.2)
                                    Text("Login :)")
                                }
                                .padding(.bottom, 75)
                            }
                            else{
                                ZStack(){
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: proxy.size.width*0.85, height: proxy.size.width*0.85)
                                        .foregroundColor(.black)
                                        .opacity(0.2)
                                    Text("Register :O")
                                }
                                .padding(.bottom, 75)

                            }
                            
                            
                            Spacer()
                            
                        }
                        
                        Spacer()
                    }
                Spacer()
            }
        }
    }
}

struct Login_Page_Previews: PreviewProvider {
    static var previews: some View {
        Login_Page()
    }
}
