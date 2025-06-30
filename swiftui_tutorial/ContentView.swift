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
        NavigationStack(path: $path) {
           
                Spacer()

                TabView(selection: $selectedTab) {
                  
                    HomeTabView(viewModel: viewModel, context: context)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(0)

               
                    SavedTabView(savedProducts: savedProducts, context: context)
                        .tabItem {
                            Label("Saved", systemImage: "bookmark.fill")
                        }
                        .tag(1)
                }
//                .navigationTitle(Text("Products").bold().font(.largeTitle)).bold()
                .navigationBarTitleDisplayMode(.inline).bold()
                .accentColor(.orange)
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
                    .scaledToFit().foregroundStyle(.tint)
                  
              
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
            DispatchQueue.main.async { [self] in
                self.products = decoded.products
                isLoading = false
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

                Text(product.description ?? "No description available.").padding(.all,20)
                    .font(.body)
                    .padding(.top)

                Spacer()
            }
            .padding(.horizontal,30)
        }
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct HomeTabView: View {
    @ObservedObject var viewModel: ProductViewModel
    let context: ModelContext

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Fetching Products...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.products) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                ProductCardView(product: product, context: context)
                                 
                                   
                                   
                              
                                
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                }
            }
        }.task {
            await viewModel.getProducts()
        }
        
    }
}
struct SavedTabView: View {
    let savedProducts: [LocalProduct]
    let context: ModelContext

    var body: some View {
        VStack(spacing: 0) {
            if savedProducts.isEmpty {
                Text("No saved products.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                   List {
                        ForEach(savedProducts) { product in
                            SavedProductCardView(product: product, context: context)
                                
                        }.onDelete(perform: { indexset in
                            self.deletezProduct(at: indexset)
                            
                        })
                    }
                    
                }
            }
        }
    
    
    
    func deletezProduct(at offets : IndexSet) {
        for offset in offets {
            let productToDelete = savedProducts[offset]
            context.delete(productToDelete)
        }
    }
    
}


struct DelayedSplashView: View {
    @State private var isReady = false
    @State private var animate = false
    @State private var backgroundColor = Color.black
    @State private var rotationAngle: Angle = .degrees(360)
    @State private var pulseScale: CGFloat = 2.0
    @StateObject var viewModel = ProductViewModel()


    var body: some View {
        Group {
            if isReady {
                ContentView()
            } else {
                ZStack {
                    Color.black
                    VStack(spacing: 50) {
                        Image("resized-image (1)")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(50)
                            .frame(width: 140, height: 140)
                            .scaleEffect(animate ? 1.0 : 0.5)
                            .opacity(animate ? 1.0 : 0.0)
                            .rotationEffect(rotationAngle)
                            .scaleEffect(pulseScale)
                            .animation(
                                .spring(duration: 1.2).delay(0.2),
                                value: animate
                            )
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7).repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: rotationAngle
                            )
                        
                        Spacer().frame(height: 20)

                        Text("Dhruvil Patel")
                            .bold()
                            .foregroundColor(.orange)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 30)
                            .scaleEffect(animate ? 1.0 : 0.8)
                            .animation(
                                .easeOut(duration: 0.8).delay(0.6),
                                value: animate
                            )
                        

                        Link(destination: URL(string: "https://github.com/Dhruvilpatel2303")!) {
                            Image(systemName: "link")
                                .frame(width: 50, height: 50)
                                
                                .foregroundColor(.white)
                                
                                .cornerRadius(25)
                                .scaleEffect(animate ? 1.5 : 0.5)
                                .rotation3DEffect(
                                    .degrees(animate ? 0 : 180),
                                    axis: (x: 0, y: 1, z: 0),
                                    
                                )
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 30)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8).delay(1.0),
                            value: animate
                        )
                    }
                }
                .onAppear {
                    // Trigger initial animations
                    withAnimation {
                        animate = true
                        backgroundColor = .blue
                    }
                    // Pulse animation for image
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        pulseScale = 1.1
                    }
                    // Rotation animation for image
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        rotationAngle = .degrees(0)
                    }
                    // Transition to ContentView after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isReady = true
                        }
                    }
                }.task {
                    await viewModel.getProducts()
                }
            }
        }
    }
}
//#Preview("Position-based Hue & Scale") {
//    ScrollView(.vertical) {
//        VStack {
//            ForEach(0 ..< 20) { _ in
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(.purple)
//                    .frame(height: 100)
//                    .visualEffect { content, proxy in
//                        let frame = proxy.frame(in: .scrollView(axis: .vertical))
//                        let parentBounds = proxy
//                            .bounds(of: .scrollView(axis: .vertical)) ??
//                            .infinite
//
//                        // The distance this view extends past the bottom edge
//                        // of the scroll view.
//                        let distance = min(0, frame.minY)
//
//                        return content
//                            .hueRotation(.degrees(frame.origin.y / 10))
//                            .scaleEffect(1 + distance / 700)
//                            .offset(y: -distance / 1.25)
//                            .brightness(-distance / 400)
//                            .blur(radius: -distance / 50)
//                    }
//            }
//        }
//        .padding()
//    }
//}
