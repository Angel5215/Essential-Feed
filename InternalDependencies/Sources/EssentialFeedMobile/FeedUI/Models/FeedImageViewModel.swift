//
// FeedImageViewModel.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void

    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    var description: String? {
        model.description
    }

    var location: String? {
        model.location
    }

    var hasLocation: Bool {
        model.location != nil
    }

    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)

        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            if let image = (try? result.get()).flatMap(UIImage.init) {
                self?.onImageLoad?(image)
            } else {
                self?.onShouldRetryImageLoadStateChange?(true)
            }
            self?.onImageLoadingStateChange?(false)
        }
    }

    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
