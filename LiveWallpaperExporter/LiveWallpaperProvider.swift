//
//  LiveWallpaperProvider.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import Foundation

class LiveWallpaperProvider: ObservableObject {
    
    @Published var items: [LiveWallpaper] = []
    
    private let dataProvier = PhotosPosterProvider()
    
    func reload() {
        items = dataProvier.posterIdentifiers().map {
            LiveWallpaper(
                id: $0,
                url: dataProvier.url(withPosterIdentifier: $0),
                videoBundleURL: dataProvier.videoBundleURL(withPosterIdentifier: $0)
            )
        }
    }
}
