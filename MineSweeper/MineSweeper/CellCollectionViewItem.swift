//
//  CellCollectionViewItem.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 08/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class CellCollectionViewItem: NSCollectionViewItem {

    var dataSource: FieldDataSource!
    var index: Int!

    override var representedObject: AnyObject? {
        didSet {
            if representedObject != nil {
                view.wantsLayer = true
                let cellType = representedObject as! Int
                textField?.textColor = NSColor.whiteColor()
                if cellType > 0 {
                    textField?.stringValue = String(cellType)
                    view.layer?.backgroundColor = CellProperties.COLOR_CELL_DARK.CGColor
                } else if cellType == CellProperties.TYPE_EMPTY {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellProperties.COLOR_CELL_EMPTY.CGColor
                } else if cellType == CellProperties.TYPE_VISITED {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellProperties.COLOR_CELL_LIGHT.CGColor
                } else if cellType == CellProperties.TYPE_MINE_FLAG || cellType == CellProperties.TYPE_EMPTY_FLAG {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellProperties.COLOR_MINE_MEDUIM.CGColor
                } else if cellType == CellProperties.TYPE_MINE {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellProperties.COLOR_CELL_EMPTY.CGColor
                } else if (cellType == CellProperties.TYPE_EMPTY_QUESTION || cellType == CellProperties.TYPE_MINE_QUESTION) {
                    textField?.textColor = NSColor.blackColor()
                    textField?.stringValue = "?"
                    view.layer?.backgroundColor = CellProperties.COLOR_CELL_GREEN.CGColor
                }
            }
        }
    }

    override func mouseUp(theEvent: NSEvent) {
        let gameOver = dataSource.uncover(index)
        if gameOver {
            view.layer?.backgroundColor = CellProperties.COLOR_MINE_DARK.CGColor
        }
    }

    override func rightMouseUp(theEvent: NSEvent) {
        dataSource.markMine(index)
    }
}