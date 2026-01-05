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
            if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
                return AlwaysFailingHTTPClient()
            }

            return super.makeRemoteClient()
        }
    }

    private final class AlwaysFailingHTTPClient: HTTPClient {
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any HTTPClientTask {
            completion(.failure(NSError(domain: "offline", code: 0)))
            return Task()
        }

        private final class Task: HTTPClientTask {
            func cancel() {}
        }
    }
#endif
