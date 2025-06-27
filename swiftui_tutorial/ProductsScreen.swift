//
//  ProductsScreen.swift
//  swiftui_tutorial
//
//  Created by Haresh Patel on 6/27/25.
//
import SwiftUI
import Foundation
import SwiftData


//https://fakestoreapi.in/api/products


func getProducts() async throws -> [Product] {
    let url = "https://fakestoreapi.in/api/products"
    let data = try Data(contentsOf: URL(string: url)!)
    let products = try JSONDecoder().decode([Product].self, from: data)
    return products
    printf(products)
    
}
