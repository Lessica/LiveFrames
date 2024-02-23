//
//  LivePhoto.swift
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
class LivePhoto: ObservableObject {

    enum State {
        case empty
		case loading(Progress)
		case successImage(Image)
        case successVideo(URL)
		case failure(Error)
    }

    enum TransferError: Error {
        case importFailed
    }

    struct LivePhotoImage: Transferable {
        let image: Image

        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return LivePhotoImage(image: image)
            }
        }
    }

    @Published private(set) var imageState: State = .empty
    @Published private(set) var videoState: State = .empty

    @Published var selection: PhotosPickerItem? = nil {
        didSet {
            if let selection {
                imageLoaded = false
                let imageProgress = loadTransferableImage(from: selection)
                imageState = .loading(imageProgress)
                videoLoaded = false
                let videoProgress = loadTransferableVideo(from: selection)
                videoState = .loading(videoProgress)
            } else {
                imageState = .empty
                videoState = .empty
            }
        }
    }

    @Published var imageLoaded: Bool = false
    @Published var videoLoaded: Bool = false

	// MARK: - Private Methods

    private func loadTransferableImage(from selection: PhotosPickerItem) -> Progress {
        return selection.loadTransferable(type: LivePhotoImage.self) { result in
            DispatchQueue.main.async {
                guard selection == self.selection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let image?):
                    self.imageState = .successImage(image.image)
                    self.imageLoaded = true
                case .success(nil):
                    self.imageState = .empty
                    self.imageLoaded = false
                case .failure(let error):
                    self.imageState = .failure(error)
                    self.imageLoaded = false
                }
            }
        }
    }

    private func loadTransferableVideo(from selection: PhotosPickerItem) -> Progress {
        return selection.loadTransferable(type: PHLivePhoto.self) { result in
            DispatchQueue.main.async {
                guard selection == self.selection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let photo?):
                    let resources = PHAssetResource.assetResources(for: photo)
                    if let video = resources.first(where: { $0.type == .pairedVideo }) {
                        var allData = Data()
                        PHAssetResourceManager.default().requestData(for: video, options: nil) { data in
                            allData += data
                        } completionHandler: { error in
                            DispatchQueue.main.async {
                                if let error {
                                    self.videoState = .failure(error)
                                    self.videoLoaded = false
                                } else {
                                    if let cachesRoot = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                                        let targetURL = cachesRoot.appending(path: "\(UUID().uuidString).MOV")
                                        try! allData.write(to: targetURL, options: [.atomic])
                                        self.videoState = .successVideo(targetURL)
                                        self.videoLoaded = true
                                    }
                                }
                            }
                        }
                    }
                case .success(nil):
                    self.videoState = .empty
                    self.videoLoaded = false
                case .failure(let error):
                    self.videoState = .failure(error)
                    self.videoLoaded = false
                }
            }
        }
    }
}
