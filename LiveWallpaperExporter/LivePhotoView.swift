//
//  LivePhotoView.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import SwiftUI
import PhotosUI

struct LivePhotoView: View {
    @StateObject var item: LivePhoto
    
    let progress = FrameExtractor.Progress()

    @Environment(\.openURL) private var openURL

    @State var isExtracting: Bool = false

    var body: some View {
        if let imageSelection = item.selection,
           let itemIdentifier = imageSelection.itemIdentifier {
            List {
                if case let .successImage(image) = item.imageState {
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .listStyle(.plain)
            .navigationTitle(itemIdentifier)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Export") {
                    guard item.videoLoaded else {
                        return
                    }
                    guard case let .successVideo(videoURL) = item.videoState else {
                        return
                    }
                    let targetURL = gDocumentsRoot.appending(path: itemIdentifier)
                    try? FileManager.default.createDirectory(at: targetURL, withIntermediateDirectories: true)
                    try? FileManager.default.setAttributes([
                        .ownerAccountID: 501,
                        .groupOwnerAccountID: 501,
                    ], ofItemAtPath: targetURL.path())
                    let extractor = FrameExtractor(
                        progress: progress,
                        videoURL: videoURL,
                        framesPerSecond: CMTimeScale(gFramesPerSecond)
                    )
                    isExtracting = true
                    DispatchQueue.global(qos: .userInitiated).async {
                        extractor.extract(to: targetURL)
                        DispatchQueue.main.async {
                            isExtracting = false
                            openURL(URL(string: "filza://view\(targetURL.path(percentEncoded: true))")!)
                        }
                    }
                }
            }
            .overlay {
                if isExtracting {
                    LoadingView(progress: progress)
                }
            }
        }
    }
}
