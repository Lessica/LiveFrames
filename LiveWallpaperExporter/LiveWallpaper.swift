//
//  LiveWallpaper.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import Foundation

struct LiveWallpaper: Identifiable {

    enum SnapshotType: String {
        case home
        case lock
    }

    enum VideoAttachmentType: String {
        case background
        case inactiveBackground
        case settlingVideo

        var rawValue: String {
            switch self {
            case .background:
                "background"
            case .inactiveBackground:
                "inactive-background"
            case .settlingVideo:
                "settling-video"
            }
        }

        var pathExtension: String {
            switch self {
            case .background:
                "HEIC"
            case .inactiveBackground:
                "HEIC"
            case .settlingVideo:
                "MOV"
            }
        }

        var pathComponent: String {
            "portrait-layer_\(rawValue).\(pathExtension)"
        }
    }

    let id: String
    let url: URL
    let videoBundleURL: URL

    func urlForRuntimeSnapshot(withType type: SnapshotType) -> URL {
        return url.appending(path: "RuntimeSnapshot-\(type.rawValue).atx")
    }
    
    func urlForVideoAttachment(withType type: VideoAttachmentType) -> URL {
        return videoBundleURL.appending(path: type.pathComponent)
    }
}
