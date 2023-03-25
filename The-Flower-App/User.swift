//
//  User.swift
//  The Flower App
//
//  Created by Jakub Górka on 25/03/2023.
//

import Foundation

class User: Identifiable, ObservableObject{
    @Published var login: String
    //@Published var password: String //Nie przechowywac tej wartosci? tylko sprawdzac czy zgadza sie haslo w core data
    
    init(l: String){
        self.login = l
    }
    
}
