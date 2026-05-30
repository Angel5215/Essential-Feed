//
// CommentsUIComposer.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import UIKit

@MainActor
public enum CommentsUIComposer {
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>

    public static func commentsComposedWith(commentsLoader: @escaping () async throws -> [ImageComment]) -> ListViewController {
        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
        let commentsViewController = makeCommentsViewController(title: ImageCommentsPresenter.title)
        commentsViewController.onRefresh = presentationAdapter.loadResource
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(controller: commentsViewController),
            loadingView: WeakReferenceVirtualProxy(commentsViewController),
            errorView: WeakReferenceVirtualProxy(commentsViewController),
            mapper: { ImageCommentsPresenter.map($0) },
        )
        return commentsViewController
    }

    // MARK: - Helpers

    private static func makeCommentsViewController(title: String) -> ListViewController {
        let controller = UIStoryboard.imageComments.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

@MainActor
final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?

    init(controller: ListViewController? = nil) {
        self.controller = controller
    }

    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(
            viewModel.comments.map { comment in
                CellController(id: comment, dataSource: ImageCommentCellController(model: comment))
            }
        )
    }

    // MARK: - Helpers

    private typealias ImagePresentationAdapter = LoadResourcePresentationAdapter<Data, WeakReferenceVirtualProxy<FeedImageCellController>>
}
