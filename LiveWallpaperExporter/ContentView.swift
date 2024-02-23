//
//  ContentView.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import SwiftUI
import PhotosUI

struct ContentView: View {

    @StateObject var provider = LiveWallpaperProvider()
    @StateObject var viewModel = LivePhoto()

    @State private var targetFramesPerSecond = gFramesPerSecond
    @State private var targetImageQuality: Double = gImageQuality

    var possibleFramesPerSecond = [24, 30, 60, 90, 120]

    var body: some View {
        NavigationView {
            List {
                Section("Target FPS") {
                    Picker("Select target FPS to export video.", selection: $targetFramesPerSecond) {
                        ForEach(possibleFramesPerSecond, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Image Quality") {
                    HStack {
                        Slider(value: $targetImageQuality, in: 0.1...1)
                        Text(String(format: "%.2f", targetImageQuality))
                            .monospacedDigit()
                    }
                }

                Section("Photos Library") {
                    PhotosPicker(selection: $viewModel.selection,
                                 matching: .livePhotos,
                                 photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "livephoto")
                            Text("Select Live Photos")
                            NavigationLink(isActive: $viewModel.imageLoaded) {
                                if let imageSelection = viewModel.selection {
                                    LivePhotoView(item: viewModel)
                                        .onDisappear {
                                            viewModel.selection = .none
                                            viewModel.imageLoaded = false
                                        }
                                }
                            } label: {
                                EmptyView()
                            }.hidden()
                        }
                    }
                }
                Section("From Theme Gallery") {
                    ForEach(provider.items) { item in
                        NavigationLink {
                            LiveWallpaperView(item: item)
                        } label: {
                            Text(item.id)
                        }
                    }
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Live Frames")
            .refreshable {
                provider.reload()
            }
        }
        .onAppear {
            provider.reload()
        }
        .onChange(of: targetImageQuality) {
            gImageQuality = targetImageQuality
        }
        .onChange(of: targetFramesPerSecond) {
            gFramesPerSecond = targetFramesPerSecond
        }
    }
}
