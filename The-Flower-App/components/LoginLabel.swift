//
//  LoginLabel.swift
//  The Flower App
//
//  Created by Jakub Górka on 25/03/2023.
//

import SwiftUI

struct LoginLabel: View {
    
    @State var text: String
    @State var textColor: Color
    
    var body: some View {
        Text(text)
            .bold()
            .font(.largeTitle)
            .foregroundColor(textColor)
    }
}
