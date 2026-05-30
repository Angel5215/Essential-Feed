//
// FeedViewAdapter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import UIKit

@MainActor
final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) async throws -> Data
    private let selection: (FeedImage) -> Void
    private let currentFeed: [FeedImage: CellController]

    init(
        currentFeed: [FeedImage: CellController] = [:],
        controller: ListViewController,
        imageLoader: @escaping (URL) async throws -> Data,
        selection: @escaping (FeedImage) -> Void,
    ) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakReferenceVirtualProxy<FeedImageCellController>>

    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller else { return }

        var currentFeed = currentFeed

        let feedSection: [CellController] = viewModel.items.map { model in
            if let controller = currentFeed[model] {
                return controller
            }

            let adapter = ImageDataPresentationAdapter { [imageLoader] in
                try await imageLoader(model.url)
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
            let cellController = CellController(id: model, dataSource: view)
            currentFeed[model] = cellController
            return cellController
        }

        if let loadMore = viewModel.loadMore {
            let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMore)
            let loadMoreController = LoadMoreCellController(callback: loadMoreAdapter.loadResource)

            loadMoreAdapter.presenter = LoadResourcePresenter(
                resourceView: FeedViewAdapter(
                    currentFeed: currentFeed,
                    controller: controller,
                    imageLoader: imageLoader,
                    selection: selection,
                ),
                loadingView: WeakReferenceVirtualProxy(loadMoreController),
                errorView: WeakReferenceVirtualProxy(loadMoreController),
                mapper: \.self,
            )

            let loadMoreSection = [CellController(id: UUID(), dataSource: loadMoreController)]
            controller.display(feedSection, loadMoreSection)
        } else {
            controller.display(feedSection)
        }
    }
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
