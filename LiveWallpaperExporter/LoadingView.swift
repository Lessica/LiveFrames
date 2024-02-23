//
//  LoadingView.swift
//  LiveWallpaperExporter
//
//  Created by 吴征 on 2024/2/22.
//

import SwiftUI

struct LoadingView: View {

    @StateObject var progress: FrameExtractor.Progress

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0, anchor: .center)

                Text("\(progress.currentIndex)/\(progress.totalIndex)")
                    .foregroundStyle(.white)
            }
        }
    }
}
