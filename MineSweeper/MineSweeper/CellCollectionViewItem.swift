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
    var disabled: Bool!

    override var representedObject: AnyObject? {
        didSet {
            if representedObject != nil {
                view.wantsLayer = true
                let cellType = representedObject as! Int
                var cellTextColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
                var cellColor = CellProperties.COLOR_CELL_EMPTY
                var cellText = ""

                if cellType > 0 {
                    cellText = String(cellType)
                    cellColor = CellProperties.COLOR_CELL_DARK
                } else if cellType == CellProperties.TYPE_VISITED {
                    cellColor = CellProperties.COLOR_CELL_LIGHT
                } else if cellType == CellProperties.TYPE_MINE_FLAG || cellType == CellProperties.TYPE_EMPTY_FLAG {
                    cellColor = CellProperties.COLOR_MINE_MEDUIM
                } else if cellType == CellProperties.TYPE_MINE {
                    cellColor = CellProperties.COLOR_CELL_EMPTY
                } else if (cellType == CellProperties.TYPE_EMPTY_QUESTION || cellType == CellProperties.TYPE_MINE_QUESTION) {
                    cellTextColor = NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
                    cellText = "?"
                    cellColor = CellProperties.COLOR_CELL_GREEN
                }

                if ((disabled) != nil && disabled) {
                    cellColor = NSColor(
                        red: cellColor.redComponent,
                        green: cellColor.greenComponent,
                        blue: cellColor.blueComponent,
                        alpha: 0.5)
                    cellTextColor = NSColor(
                        red: cellTextColor.redComponent,
                        green: cellTextColor.greenComponent,
                        blue: cellTextColor.blueComponent,
                        alpha: 0.5)
                    if cellType == CellProperties.TYPE_MINE {
                        cellColor = CellProperties.COLOR_MINE_MEDUIM
                    }
                    if cellType == CellProperties.TYPE_MINE_EXPLODED {
                        cellColor = CellProperties.COLOR_MINE_DARK
                        cellText = "!"
                    }
                }

                view.layer?.backgroundColor = cellColor.CGColor
                textField?.stringValue = cellText
                textField?.textColor = cellTextColor
            }
        }
    }

    override func mouseUp(theEvent: NSEvent) {
        if !disabled {
            dataSource.uncover(index)
        }
    }

    override func rightMouseUp(theEvent: NSEvent) {
        if !disabled {
            dataSource.markMine(index)
        }
    }
}