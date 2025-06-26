//
//  ContentView.swift
//  swiftui_tutorial
//
//  Created by Haresh Patel on 6/26/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State var textInput: String = ""
    var body: some View {
     
     
        
        TextField("Enter Text", text: $textInput)
        
            .border(Color.red, width: 3).cornerRadius(50)
            .padding().background(.black).textFieldStyle(.roundedBorder).keyboardType(.default).background(Color.red).fontWeight(.bold).foregroundColor(.red).font(.system(size: 30, weight: .bold, design: .default))
        
        Text(textInput)
     
    }
}


#Preview {
   TextEditorView()
}

struct TextEditorView : View {
    @State var isClicked: Bool = false
    var body: some View {
       
        
        Image(systemName: "externaldrive.fill.badge.person.crop").resizable().frame(width:150,height: 100)
        Button(
            
            action: {
           if isClicked==false {
               isClicked=true
               print("Added to cart")
            }
        }, label: {
            Text("Add to Cart").font(.system(size: 30, weight: .bold, design: .default))
        }).frame(width: 200, height: 50).padding(10).contrast(3).cornerRadius(200).shadow(radius: 5)
    }
}

