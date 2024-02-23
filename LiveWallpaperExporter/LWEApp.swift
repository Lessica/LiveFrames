//
//  LWEApp.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import SwiftUI

let gDocumentsRoot = URL(filePath: "/private/var/mobile/Documents")
var gFramesPerSecond: Int = 60
var gImageQuality: Double = 0.9

@main
struct LWEApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
