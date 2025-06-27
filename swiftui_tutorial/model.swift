//
//  model.swift
//  swiftui_tutorial
//
//  Created by Haresh Patel on 6/27/25.
//
import Foundation


struct ProductModel : Codable{
    
    let status: String
    let message: String
    let products : Product
    
}

struct Product : Codable{
    let id: Int
    let title : String
    let image : String
    let price : Double
    let description : String
    let brand : String
    let model : String
    let color : String
    let category : String
    let discount : Double
    
    
}
