//
// WeakReferenceVirtualProxy.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

final class WeakReferenceVirtualProxy<Object: AnyObject> {
    private weak var object: Object?

    init(_ object: Object) {
        self.object = object
    }
}

extension WeakReferenceVirtualProxy: FeedLoadingView where Object: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakReferenceVirtualProxy: FeedImageView where Object: FeedImageView, Object.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakReferenceVirtualProxy: FeedErrorView where Object: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}
