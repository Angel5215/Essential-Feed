//
// CellController.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

public struct CellController {
    let id: any Hashable & Sendable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?

    public init(id: any Hashable & Sendable, dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: nonisolated Equatable {
    public nonisolated static func == (lhs: CellController, rhs: CellController) -> Bool {
        AnyHashable(lhs.id) == AnyHashable(rhs.id)
    }
}

extension CellController: nonisolated Hashable {
    public nonisolated func hash(into hasher: inout Hasher) {
        // swiftformat:disable:next redundantSelf
        let id = AnyHashable(self.id)
        hasher.combine(id)
    }
}
