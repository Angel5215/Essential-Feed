//
// CombineHelpers+Logging.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import os
import UIKit

extension Publisher {
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed to load URL: \(url) with error: \(error.localizedDescription).")
            }
        })
        .eraseToAnyPublisher()
    }

    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        let startTime = CACurrentMediaTime()
        return handleEvents { _ in
            logger.trace("Started loading url: \(url).")
        } receiveCompletion: { _ in
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finished loading URL: \(url) in \(elapsed) seconds.")
        }
        .eraseToAnyPublisher()
    }

    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveCompletion: { result in
            if case .failure = result {
                logger.trace("Cache miss for url: \(url)")
            }
        })
        .eraseToAnyPublisher()
    }
}
