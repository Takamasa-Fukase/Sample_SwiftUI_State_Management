//
//  ContentView.swift
//  Sample_SwiftUI_State_Management
//
//  Created by ウルトラ深瀬 on 28/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ChildViewA()
                .frame(width: .infinity, height: 200)
            ChildViewB()
                .frame(width: .infinity, height: 200)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct ChildViewA: View {
    var image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
        }else {
            Color.red
        }
    }
}

struct ChildViewB: View {
    var image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
        }else {
            Color.blue
        }
    }
}
