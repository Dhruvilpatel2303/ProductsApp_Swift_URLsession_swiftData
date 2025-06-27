//
//  ContentView.swift
//  swiftui_tutorial
//
//  Created by Haresh Patel on 6/26/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var viewModel = ProductViewModel()
    @State var selectedTab = 0
    @Environment(\.modelContext) private var context
    @Query var savedProducts: [LocalProduct]
    @State var path = NavigationPath()
    
    var body: some View {
    
        ZStack {
            BackgroundGradient().frame(width: .infinity, height: .infinity)
            // Gradient background
            
            
            
            NavigationStack {
                TabView(selection: $selectedTab) {
                    // Home Tab
                    VStack(spacing: 0) {
                        if viewModel.isLoading {
                            VStack {
                               
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(1.5)
                                    .padding()
                                Text("Fetching Products...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else if let error = viewModel.errorMessage {
                            Text("Error: \(error)")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.products) { product in
                                        NavigationLink {
                                            ProductDetailView(product: product)
                                        } label: {
                                            ProductCardView(product: product, context: context)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }.padding(.vertical)
                                }.padding(.horizontal)
                              
                            }
                        }
                    }
                    .task {
                        await viewModel.getProducts()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                    
                    // Saved Products Tab
                    VStack(spacing: 0) {
                        if savedProducts.isEmpty {
                       
                            Text("No saved products.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(savedProducts) { product in
                                        SavedProductCardView(product: product,context:  context)
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .tabItem {
                        Label("Saved", systemImage: "bookmark.fill")
                    }
                    .tag(1)
                    
                    // Placeholder Sun Dust Tab
                    VStack {
                        Image(systemName: "sun.dust")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.orange)
                        Text("Sun Dust")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .tabItem {
                        Label("Sun Dust", systemImage: "sun.dust")
                    }
                    .tag(2)
                }
                .navigationBarBackButtonHidden(true)
                .accentColor(.orange)
              
            }
        }
    }
}

// Product Card View
struct ProductCardView: View {
    let product: Product
    let context: ModelContext

    var body: some View {
      
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: product.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                  
              
            } placeholder: {
                ProgressView()
                    .frame(width: 130, height: 100)
            }
            .frame(width: 130, height:.infinity)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(radius: 10)

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title ?? "No Title")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Text("₹\(product.price ?? 0, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: {
                    let new = LocalProduct(
                        id: product.id,
                        title: product.title,
                        price: product.price,
                        image: product.image
                    )
                    context.insert(new)
                }) {
                    Text("Add to Saved")
                        
                      
                }  .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                  
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding(.vertical, 8)
        }
        .padding()
        
        .background(
            BackgroundGradient()
        ).cornerRadius(30)
    }
}
// Saved Product Card View
struct SavedProductCardView: View {
    let product: LocalProduct
    let context: ModelContext
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
                    .frame(width: 130, height: 100)
            }
            .frame(width: 130, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("₹\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                
                Button(action: {
                    
                    context.delete(product)
                    
                }) {
                    Text("Remove Saved")
                        
                      
                }  .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                  
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding(.vertical, 8)
            
            Spacer()
        }
        .padding()
        
        .background(
            BackgroundGradient()
        ).cornerRadius(30)
    }
}

#Preview {
    ContentView()
}



struct ProductModel: Codable {
    let status: String
    let message: String
    let products: [Product]
}

struct Product: Codable, Identifiable {
    let id: Int?
    let title: String?
    let image: String?
    let price: Double?
    let description: String?
    let brand: String?
    let model: String?
    let color: String?
    let category: String?
    let discount: Double?
}



class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func getProducts() async {
        isLoading = true
        errorMessage = nil

        let urlString = "https://fakestoreapi.in/api/products"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ProductModel.self, from: data)
            DispatchQueue.main.async {
                self.products = decoded.products
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}



@Model
class LocalProduct {
    @Attribute(.unique) var externalId: Int
    var title: String
    var price: Double
    var image: String

    init(id: Int?, title: String?, price: Double?, image: String?) {
        self.externalId = id ?? -1
        self.title = title ?? "Untitled"
        self.price = price ?? 0.0
        self.image = image ?? ""
    }
}

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.black, .blue.opacity(0.4),.red]),
            startPoint: .top,
            endPoint: .bottomLeading
        )
    
        
    }
}
struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: product.image ?? "")) { image in
                    image
                        .resizable()
                        
                        .frame(width : .infinity, height: 350)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } placeholder: {
                    ProgressView()
                        .frame(height: 250)
                }

                Text(product.title ?? "No Title")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("₹\(product.price ?? 0, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(product.description ?? "No description available.")
                    .font(.body)
                    .padding(.top).frame(width : 400, height :200,alignment: .center)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
