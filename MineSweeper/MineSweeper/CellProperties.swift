//
//  CellProperties.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 08/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class CellProperties {
    static let CELL_WIDTH = 25
    static let CELL_HEIGHT = 25

    static let COLOR_MINE_LIGHT = NSColor(red: 1.0, green: 0.38, blue: 0.37, alpha: 1.0)
    static let COLOR_MINE_MEDUIM = NSColor(red: 1.0, green: 0.28, blue: 0.27, alpha: 1.0)   // 0xFF4746
    static let COLOR_MINE_DARK = NSColor(red: 0.70, green: 0.13, blue: 0.12, alpha: 1.0)    // 0xB2201F
    static let COLOR_CELL_EMPTY = NSColor(red: 1.0, green: 0.99, blue: 0.38, alpha: 1.0)    // 0xFFFD60
    static let COLOR_CELL_LIGHT = NSColor(red: 0.14, green: 0.54, blue: 0.80, alpha: 1.0)   // 0x248ACC
    static let COLOR_CELL_DARK = NSColor(red: 0.16, green: 0.49, blue: 0.70, alpha: 1.0)    // 0x287DB2
    static let COLOR_CELL_ORANGE = NSColor(red: 0.95, green: 0.47, blue: 0.0, alpha: 1.0)

    static let TYPE_EMPTY: Int = 0
    static let TYPE_MINE: Int = -1
    static let TYPE_VISITED: Int = -2
    static let TYPE_MINE_FLAG: Int = -3
    static let TYPE_EMPTY_FLAG: Int = -4
    static let TYPE_MINE_QUESTION: Int = -5
    static let TYPE_EMPTY_QUESTION: Int = -6
    static let TYPE_MINE_EXPLODED: Int = -7
}
