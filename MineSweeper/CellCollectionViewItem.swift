//
//  CellCollectionIViewItem.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 23/04/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class CellCollectionViewItem: NSCollectionViewItem {

    var index: Int!
    var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override var representedObject: AnyObject? {
        didSet {
            if representedObject != nil {
                let cellType = representedObject as! Int
                if cellType > 0 {
                    textField?.stringValue = String(cellType)
                    view.layer?.backgroundColor = CellColors.CELL_DARK.CGColor
                } else if cellType == CellType.EMPTY {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColors.CELL_EMPTY.CGColor
                } else if cellType == CellType.VISITED {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColors.CELL_LIGHT.CGColor
                } else if cellType == CellType.RIGHT_FLAG || cellType == CellType.WRONG_FLAG {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColors.MINE_LIGHT.CGColor
                } else if cellType == CellType.MINE {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColors.CELL_EMPTY.CGColor
                }
            } else {
                view.layer?.backgroundColor = nil
                textField?.stringValue = ""
            }
            view.layer?.borderColor = NSColor.blackColor().CGColor
        }
    }

    override func mouseUp(theEvent: NSEvent) {
        let gameOver = dataSource.uncover(index)
        if gameOver {
            view.layer?.backgroundColor = CellColors.MINE_DARK.CGColor
        }
    }

    override func rightMouseUp(theEvent: NSEvent) {
        dataSource.mineSet(index)
    }

}
