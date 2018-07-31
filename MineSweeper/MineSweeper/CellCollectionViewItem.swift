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
    var value: Int!

    override func viewWillLayout() {
        view.wantsLayer = true
        let cellType = value
        var cellTextColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
        var cellColor = CellProperties.COLOR_CELL_EMPTY
        var cellText = ""

        if cellType! > 0 {
            cellText = cellType!.description
            cellColor = CellProperties.COLOR_CELL_DARK
        } else if cellType == CellProperties.TYPE_VISITED {
            cellColor = CellProperties.COLOR_CELL_LIGHT
        } else if cellType == CellProperties.TYPE_MINE_FLAG || cellType == CellProperties.TYPE_EMPTY_FLAG {
            cellColor = CellProperties.COLOR_MINE_MEDUIM
        } else if cellType == CellProperties.TYPE_MINE {
            cellColor = CellProperties.COLOR_CELL_EMPTY
        } else if (cellType == CellProperties.TYPE_EMPTY_QUESTION || cellType == CellProperties.TYPE_MINE_QUESTION) {
            cellText = "?"
            cellColor = CellProperties.COLOR_CELL_ORANGE
        }

        if (disabled != nil && disabled) {    // display game over state
            if cellType == CellProperties.TYPE_MINE {
                cellColor = CellProperties.COLOR_MINE_LIGHT
            } else if cellType == CellProperties.TYPE_MINE_FLAG {
                cellText = "✓"
            } else if cellType == CellProperties.TYPE_EMPTY_FLAG {
                cellText = "✗"
            } else if cellType == CellProperties.TYPE_MINE_EXPLODED {
                cellColor = CellProperties.COLOR_MINE_DARK
                cellText = "!"
            }

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
        }

        view.layer?.backgroundColor = cellColor.cgColor
        textField?.stringValue = cellText
        textField?.textColor = cellTextColor
    }

    override func mouseUp(with theEvent: NSEvent) {
        if !disabled {
            dataSource.uncover(index)
            if theEvent.clickCount > 1 {
                dataSource.uncoverNeighborsOf(index)
            }
        }
    }

    override func rightMouseUp(with theEvent: NSEvent) {
        if !disabled {
            dataSource.markMine(index)
        }
    }
}
