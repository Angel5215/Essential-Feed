//
// CellController.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

public struct CellController {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?

    public init(dataSource: UITableViewDataSource, delegate: UITableViewDelegate? = nil, dataSourcePrefetching: UITableViewDataSourcePrefetching? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.dataSourcePrefetching = dataSourcePrefetching
    }

    public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = dataSource
    }
}
