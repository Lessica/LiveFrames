//
//  ContentView.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import SwiftUI

struct ContentView: View {
    let dataProvier = PhotosPosterProvider()
    
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
