//
// FeedViewAdapter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import UIKit

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        typealias ImagePresentationAdapter = FeedImageDataLoaderPresentationAdapter<WeakReferenceVirtualProxy<FeedImageCellController>, UIImage>
        controller?.display(
            viewModel.feed.map { model in
                let adapter = ImagePresentationAdapter(model: model, imageLoader: imageLoader)
                let view = FeedImageCellController(delegate: adapter)
                adapter.presenter = FeedImagePresenter(
                    view: WeakReferenceVirtualProxy(view),
                    imageTransformer: UIImage.init,
                )
                return view
            }
        )
    }
}
