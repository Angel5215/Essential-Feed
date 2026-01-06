//
// DebuggingSceneDelegate.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

#if DEBUG
    import EssentialFeed
    import UIKit

    final class DebuggingSceneDelegate: SceneDelegate {
        override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let _ = (scene as? UIWindowScene) else { return }

            if CommandLine.arguments.contains("-reset") {
                try? FileManager.default.removeItem(at: localStoreURL)
            }

            super.scene(scene, willConnectTo: session, options: connectionOptions)
        }

        override func makeRemoteClient() -> HTTPClient {
            if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
                return DebuggingHTTPClient(connectivity: connectivity)
            }

            return super.makeRemoteClient()
        }
    }

    private final class DebuggingHTTPClient: HTTPClient {
        private let connectivity: String

        init(connectivity: String) {
            self.connectivity = connectivity
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any HTTPClientTask {
            switch connectivity {
            case "online":
                completion(.success(makeSuccessfulResponse(for: url)))
            default:
                completion(.failure(NSError(domain: "offline", code: 0)))
            }
            return Task()
        }

        private final class Task: HTTPClientTask {
            func cancel() {}
        }

        private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (makeData(for: url), response)
        }

        private func makeData(for url: URL) -> Data {
            switch url.absoluteString {
            case "https://image.com":
                makeImageData()
            default:
                makeFeedData()
            }
        }

        private func makeImageData() -> Data {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            return UIGraphicsImageRenderer(size: rect.size)
                .image { context in
                    UIColor.red.setFill()
                    context.fill(rect)
                }
                .pngData()!
        }

        private func makeFeedData() -> Data {
            try! JSONSerialization.data(
                withJSONObject: [
                    "items": [
                        ["id": UUID().uuidString, "image": "https://image.com"],
                        ["id": UUID().uuidString, "image": "https://image.com"],
                    ]
                ]
            )
        }
    }
#endif
