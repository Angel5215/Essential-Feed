//
// FeedViewAdapter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import UIKit

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void

    init(
        controller: ListViewController? = nil,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void,
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    func display(_ viewModel: Paginated<FeedImage>) {
        let feedSection: [CellController] = viewModel.items.map { model in
            let adapter = ImageDataPresentationAdapter { [imageLoader] in
                imageLoader(model.url)
            }
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                },
            )
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakReferenceVirtualProxy(view),
                loadingView: WeakReferenceVirtualProxy(view),
                errorView: WeakReferenceVirtualProxy(view),
                mapper: UIImage.tryMake,
            )
            return CellController(id: model, dataSource: view)
        }

        if let loadMorePublisher = viewModel.loadMorePublisher {
            let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
            let loadMoreController = LoadMoreCellController(callback: loadMoreAdapter.loadResource)

            loadMoreAdapter.presenter = LoadResourcePresenter(
                resourceView: self,
                loadingView: WeakReferenceVirtualProxy(loadMoreController),
                errorView: WeakReferenceVirtualProxy(loadMoreController),
                mapper: \.self,
            )

            let loadMoreSection = [CellController(id: UUID(), dataSource: loadMoreController)]
            controller?.display(feedSection, loadMoreSection)
        } else {
            controller?.display(feedSection)
        }
    }

    // MARK: - Helpers

    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakReferenceVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
}

extension UIImage {
    private struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }

        return image
    }
}
