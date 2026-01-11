//
// MainQueueDispatchDecorator.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialFeed
import Foundation

final class MainQueueDispatchDecorator<Value> {
    private let value: Value

    init(value: Value) {
        self.value = value
    }

    func dispatch(action: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: action)
        }
        action()
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where Value == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        value.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
