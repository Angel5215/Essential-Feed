//
// SharedTestHelpers.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
