//
//  ContentView.swift
//  Sample_SwiftUI_State_Management
//
//  Created by ウルトラ深瀬 on 28/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var color = Color.red
    
    var body: some View {
        VStack {
            ChildViewA(borderColor: color)
                .frame(width: .infinity, height: 200)
            ChildViewA_2(borderColor: color)
                .frame(width: .infinity, height: 200)
            ChildViewB(borderColor: color)
                .frame(width: .infinity, height: 200)
            Button {
                if color == .red {
                    color = .blue
                }else {
                    color = .red
                }
            } label: {
                Text("親ビューを再描画")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct ChildViewA: View {
    struct ChildViewAState {
        var count = 0
        var image: UIImage?
    }
    
    let borderColor: Color
    @State private var state: ChildViewAState = .init()
    
    init(borderColor: Color) {
        self.borderColor = borderColor
    }
    
    var body: some View {
        HStack {
            if let image = state.image {
                Image(uiImage: image)
                    .resizable()
            }else {
                Color.gray
            }
            VStack {
                Text("今は\(state.count)番の画像")
                
                Spacer().frame(height: 40)
                
                Button {
                    update()
                } label: {
                    Text("更新")
                }
            }
        }
        .padding(.all, 16)
        .border(borderColor, width: 10)
    }
    
    func update() {
        if state.count == 2 {
            state.count = 0
        }else {
            state.count += 1
        }
        
        Task {
            do {
                self.state.image = try await DataSource.getImage(from: URL(string: DataSource.imageUrls[state.count])!)
                print("image: \(state.image)")
                print("代入した: \(self.state.image)")
            }catch {
                print(error)
            }
        }
    }
}

struct ChildViewA_2: View {
    struct ChildViewA_2State {
        var count = 0
        var image: UIImage?
    }
    
    struct Logic {
        static func nextCount(count: Int) -> Int {
            if count == 2 {
                return 0
            }else {
                return count + 1
            }
        }
        
        static func fetch(count: Int, result: @escaping ((UIImage) -> Void)) {
            Task {
                do {
                    result(try await DataSource.getImage(from: URL(string: DataSource.imageUrls[count])!))
                }catch {
                    print(error)
                }
            }
        }
    }
    
    let borderColor: Color
    @State private var state: ChildViewA_2State = .init()
    
    init(borderColor: Color) {
        self.borderColor = borderColor
    }
    
    var body: some View {
        HStack {
            if let image = state.image {
                Image(uiImage: image)
                    .resizable()
            }else {
                Color.gray
            }
            VStack {
                Text("今は\(state.count)番の画像")
                
                Spacer().frame(height: 40)
                
                Button {
                    state.count = Logic.nextCount(count: state.count)
                    Logic.fetch(count: state.count) { image in
                        state.image = image
                    }
                } label: {
                    Text("更新")
                }
            }
        }
        .padding(.all, 16)
        .border(borderColor, width: 10)
    }
}

class ChildViewBState: ObservableObject {
    @Published var count: Int = 0
    @Published var image: UIImage?
    
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
    let borderColor: Color
    @StateObject var state = ChildViewBState()
    
    /* 
     下記の書き方だと、親ビューの再描画でObservableObjectのインスタンスも再生成されるので状態がリセットされてしまう
     @ObservedObject var state = ChildViewBState()
     @ObservedObjectを使う場合でも、子ビュー内部でインスタンス化せずに、親ビューでインスタンス化して保持しているものを注入すればこれは防げるが、そうすると子ビューが破棄されても注入したオブジェクトは自動的には破棄されないので別途連動して破棄させる仕組みを考慮する必要があるが、それをしたくないならStateObjectにすれば自動でビューと一緒にオブジェクトも破棄してもらえるので考えなくてよくなる。
     */
    
    init(
        borderColor: Color
    ) {
        self.borderColor = borderColor
    }
    
    var body: some View {
        HStack {
            if let image = state.image {
                Image(uiImage: image)
                    .resizable()
            }else {
                Color.gray
            }
            VStack {
                Text("今は\(state.count)番の画像")
                
                Spacer().frame(height: 40)
                
                Button {
                    state.update()
                } label: {
                    Text("更新")
                }
            }
        }
        .padding(.all, 16)
        .border(borderColor, width: 10)
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
