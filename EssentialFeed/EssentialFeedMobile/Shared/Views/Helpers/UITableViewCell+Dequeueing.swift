//
// UITableViewCell+Dequeueing.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell>() -> Cell {
        let identifier = String(describing: Cell.self)
        guard let cell = dequeueReusableCell(withIdentifier: identifier) as? Cell else {
            fatalError("No \(Cell.self) registered for identifier \(identifier)")
        }
        return cell
    }
}
