//
//  LiveWallpaperView.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import SwiftUI
import CoreMedia

private struct ImageRow: View {
    let lockURL: URL
    let homeURL: URL
    
    var body: some View {
        HStack {
            VStack {
                Text("Lockscreen")
                    .fontWeight(.semibold)
                if let lockData = try? Data(contentsOf: lockURL), let lockImage = UIImage(data: lockData) {
                    Image(uiImage: lockImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            VStack {
                Text("Desktop")
                    .fontWeight(.semibold)
                if let homeData = try? Data(contentsOf: homeURL), let homeImage = UIImage(data: homeData) {
                    Image(uiImage: homeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

private struct DetailRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.semibold)
            Text(detail)
                .lineLimit(2)
                .truncationMode(.head)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}

struct LiveWallpaperView: View {
    let item: LiveWallpaper
    let progress = FrameExtractor.Progress()

    @Environment(\.openURL) private var openURL

    @State var isExtracting: Bool = false

    var body: some View {
        List {
            ImageRow(
                lockURL: item.urlForRuntimeSnapshot(withType: .lock),
                homeURL: item.urlForRuntimeSnapshot(withType: .home)
            )
            DetailRow(title: "URL", detail: item.url.path(percentEncoded: false))
                .onTapGesture {
                    openURL(URL(string: "filza://view\(item.url.path(percentEncoded: true))")!)
                }
            DetailRow(title: "Lockscreen Snapshot", detail: item.urlForRuntimeSnapshot(withType: .lock).path(percentEncoded: false))
                .onTapGesture {
                    openURL(URL(string: "filza://view\(item.urlForRuntimeSnapshot(withType: .lock).path(percentEncoded: true))")!)
                }
            DetailRow(title: "Desktop Snapshot", detail: item.urlForRuntimeSnapshot(withType: .home).path(percentEncoded: false))
                .onTapGesture {
                    openURL(URL(string: "filza://view\(item.urlForRuntimeSnapshot(withType: .home).path(percentEncoded: true))")!)
                }
            DetailRow(title: "Video", detail: item.urlForVideoAttachment(withType: .settlingVideo).path(percentEncoded: false))
                .onTapGesture {
                    openURL(URL(string: "filza://view\(item.urlForVideoAttachment(withType: .settlingVideo).path(percentEncoded: true))")!)
                }
        }
        .listStyle(.plain)
        .navigationTitle(item.id)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Export") {
                let targetURL = gDocumentsRoot.appending(path: item.id)
                try? FileManager.default.createDirectory(at: targetURL, withIntermediateDirectories: true)
                try? FileManager.default.setAttributes([
                    .ownerAccountID: 501,
                    .groupOwnerAccountID: 501,
                ], ofItemAtPath: targetURL.path())
                let extractor = FrameExtractor(
                    progress: progress,
                    videoURL: item.urlForVideoAttachment(withType: .settlingVideo),
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
