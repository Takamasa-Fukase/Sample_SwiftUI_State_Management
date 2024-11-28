//
//  ContentView.swift
//  Sample_SwiftUI_State_Management
//
//  Created by ウルトラ深瀬 on 28/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var id = UUID()
    
    var body: some View {
        VStack {
            ChildViewA()
                .frame(width: .infinity, height: 200)
            ChildViewB()
                .frame(width: .infinity, height: 200)
            Button {
                id = .init()
            } label: {
                Text("再描画")
            }
            Text("id: \(id.uuidString)")
        }
        .id(id)
        .padding()
    }
}

#Preview {
    ContentView()
}

struct ChildViewA: View {
    @State var count = 0
    @State var image: UIImage?
    
    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            }else {
                Color.gray
            }
            VStack {
                Text("今は\(count)番の画像")
                
                Spacer().frame(height: 40)
                
                Button {
                    update()
                } label: {
                    Text("更新")
                }
            }
        }
    }
    
    func update() {
        if count == 2 {
            count = 0
        }else {
            count += 1
        }
        
        Task {
            do {
                self.image = try await DataSource.getImage(from: URL(string: DataSource.imageUrls[count])!)
                print("image: \(image)")
                print("代入した: \(self.image)")
            }catch {
                print(error)
            }
        }
    }
}

struct ChildViewB: View {
    @State var count = 0
    @State var image: UIImage?
    
    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            }else {
                Color.gray
            }
            VStack {
                Text("今は\(count)番の画像")
                
                Spacer().frame(height: 40)
                
                Button {
                    update()
                } label: {
                    Text("更新")
                }
            }
        }
    }
    
    func update() {
        if count == 2 {
            count = 0
        }else {
            count += 1
        }
        
        Task {
            do {
                self.image = try await DataSource.getImage(from: URL(string: DataSource.imageUrls[count])!)
                print("image: \(image)")
                print("代入した: \(self.image)")
            }catch {
                print(error)
            }
        }
    }
}

struct DataSource {
    static let imageUrls = [
        "https://cdn.macaro-ni.jp/image/summary/32/32145/d642febe8bc7c7d31cc0b002ae327473.jpg?p=1x1",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC74P5Y1lSq0q-38xX-TB6CzhX_79CAEyP3A&s",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsV6BmIOP3qg5IyYOGuiRvYrnIq3Ksd946zw&s"
    ]
    
    static func getImage(from url: URL) async throws -> UIImage {
        let session = URLSession(configuration: .default)
        let (data, _) = try await session.data(from: url)
        return UIImage(data: data) ?? UIImage()
    }
}
