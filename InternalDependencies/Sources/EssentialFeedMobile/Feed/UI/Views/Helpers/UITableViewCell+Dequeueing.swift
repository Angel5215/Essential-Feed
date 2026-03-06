//
// UITableViewCell+Dequeueing.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell>() -> Cell {
        let identifier = String(describing: Cell.self)
        return dequeueReusableCell(withIdentifier: identifier) as! Cell
    }
}
