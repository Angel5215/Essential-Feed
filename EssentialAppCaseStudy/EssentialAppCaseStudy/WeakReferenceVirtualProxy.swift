//
// WeakReferenceVirtualProxy.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

final class WeakReferenceVirtualProxy<Object: AnyObject> {
    private weak var object: Object?

    init(_ object: Object) {
        self.object = object
    }
}

extension WeakReferenceVirtualProxy: ResourceLoadingView where Object: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakReferenceVirtualProxy: FeedImageView where Object: FeedImageView, Object.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakReferenceVirtualProxy: ResourceErrorView where Object: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}
