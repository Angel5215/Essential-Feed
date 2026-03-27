//
// CombineHelpers.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialFeed
import Foundation

// Wraps the `LocalFeedLoader` into a Combine `Publisher`
// The `FeedLoader` was no longer necessary as we don't require the strategy (remote/local) anymore.
public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>

    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>

    func getPublisher(from url: URL) -> Publisher {
        var task: HTTPClientTask?

        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }
}

// Replaces `FeedLoaderCacheDecorator`
extension Publisher {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == [FeedImage] {
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }

    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == Paginated<FeedImage> {
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }

    func saveIgnoringResult(_ feed: Paginated<FeedImage>) {
        saveIgnoringResult(feed.items)
    }
}

// Replaces `FeedLoaderWithFallbackComposite` and `FeedImageDataLoaderWithFallbackComposite`
extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

// Replaces the `MainQueueDispatchDecorator`
extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }

    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: DispatchQueue.SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            action()
        }

        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(
            after date: SchedulerTimeType,
            interval: SchedulerTimeType.Stride,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void,
        ) -> any Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }

        // MARK: - Main Queue helpers

        static let shared = ImmediateWhenOnMainQueueScheduler()
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max

        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }

        private var isMainQueue: Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
    }
}

// Wraps implementations for `FeedImageDataLoader` into Combine Publishers
public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>

    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?

        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }
}

// Replaces `FeedImageDataLoaderCacheDecorator`
extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        })
        .eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        try? save(data, for: url)
    }
}

// MARK: - Pagination

// Bridges the closure-based API from the Paginated<Item> to Combine
public extension Paginated {
    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        loadMore.map { loadMore in
            {
                Deferred {
                    Future(loadMore)
                }
                .eraseToAnyPublisher()
            }
        }
    }

    init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
        self.init(
            items: items,
            loadMore: loadMorePublisher.map { publisher in
                { completion in
                    publisher().subscribe(
                        Subscribers.Sink(
                            receiveCompletion: { result in
                                if case let .failure(error) = result {
                                    completion(.failure(error))
                                }
                            },
                            receiveValue: { result in
                                completion(.success(result))
                            },
                        )
                    )
                }
            },
        )
    }
}
