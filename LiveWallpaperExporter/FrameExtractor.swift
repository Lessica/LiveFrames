//
//  FrameExtractor.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import AVFoundation
import UIKit

@MainActor
class FrameExtractor {

    class Progress: ObservableObject {
        @Published var currentIndex: Int = 0
        @Published var totalIndex: Int = 0
    }

    let videoURL: URL
    let videoDuration: Float64
    let framesPerSecond: CMTimeScale
    let progress: Progress
    let cropRect: CGRect?

    private let frameGenerator: AVAssetImageGenerator!
    private var currentPosition: Float64 = 0

    init(progress: Progress, videoURL: URL, framesPerSecond: CMTimeScale, cropRect: CGRect? = nil) {
        self.progress = progress
        self.videoURL = videoURL
        let asset = AVAsset(url: videoURL)
        self.videoDuration = CMTimeGetSeconds(asset.duration)
        self.framesPerSecond = framesPerSecond
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        self.frameGenerator = generator
        self.cropRect = cropRect
    }

    func extract(to url: URL) {
        var lockGroup = DispatchGroup()
        var timesArray = [NSValue]()
        let totalFrames = Float64(framesPerSecond) * videoDuration
        var timeFrame: CMTime
        for i in 0...Int(totalFrames) {
            timeFrame = CMTime(value: CMTimeValue(i), timescale: CMTimeScale(framesPerSecond))
            let timeValue = NSValue(time: timeFrame)
            timesArray.append(timeValue)
            lockGroup.enter()
        }
        progress.currentIndex = 0
        progress.totalIndex = timesArray.count
        var blockImage: CGImage?
        let blockCropRect = cropRect
        var blockProgress = 0
        frameGenerator.generateCGImagesAsynchronously(forTimes: timesArray) { [weak self] requestedTime, image, actualTime, result, error in
            defer {
                blockProgress += 1
                lockGroup.leave()
                DispatchQueue.main.async {
                    self?.progress.currentIndex += 1
                }
            }
            let inputImage: CGImage?
            if let image {
                inputImage = image
            } else {
                inputImage = blockImage
            }
            guard let inputImage else {
                return
            }
            var croppedImage: CGImage?
            if let blockCropRect {
                croppedImage = inputImage.cropping(to: blockCropRect)
            } else {
                croppedImage = inputImage
            }
            guard let croppedImage else {
                return
            }
            blockImage = croppedImage
            let uiImage = UIImage(cgImage: croppedImage)
            guard let data = uiImage.jpegData(compressionQuality: gImageQuality) else {
                return
            }
            let fileName = "image_\(String(format: "%05d", blockProgress)).jpg"
            let filePath = url.appending(path: fileName)
            debugPrint("extracted \(fileName)")
            try? data.write(to: filePath, options: [.atomic])
        }
        lockGroup.wait()
    }

    func reset() {
        currentPosition = 0
    }
}
