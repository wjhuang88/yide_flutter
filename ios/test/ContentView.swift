//
//  ContentView.swift
//  test
//
//  Created by Gerald Huang on 2023/12/15.
//  Copyright © 2023 The Chromium Authors. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
