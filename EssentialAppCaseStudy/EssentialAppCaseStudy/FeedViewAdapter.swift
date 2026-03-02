//
// FeedViewAdapter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import UIKit

final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(controller: FeedViewController? = nil, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.display(
            viewModel.feed.map { model in
                let adapter = ImagePresentationAdapter { [imageLoader] in
                    imageLoader(model.url)
                }
                let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model), delegate: adapter)
                adapter.presenter = LoadResourcePresenter(
                    resourceView: WeakReferenceVirtualProxy(view),
                    loadingView: WeakReferenceVirtualProxy(view),
                    errorView: WeakReferenceVirtualProxy(view),
                    mapper: { data in
                        guard let image = UIImage(data: data) else { throw InvalidImageData() }
                        return image
                    },
                )
                return view
            }
        )
    }

    // MARK: - Helpers

    private typealias ImagePresentationAdapter = LoadResourcePresentationAdapter<Data, WeakReferenceVirtualProxy<FeedImageCellController>>

    private struct InvalidImageData: Error {}
}
