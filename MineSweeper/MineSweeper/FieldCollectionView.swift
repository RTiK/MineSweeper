//
//  FieldCollectionView.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 06/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class FieldCollectionView: NSCollectionView {

    private var fieldDimensions: NSSize!
    private var numberOfMines: Int!

    override func awakeFromNib() {
        self.registerNib(NSNib(nibNamed: "CellCollectionViewItem", bundle: nil), forItemWithIdentifier: "cellItem")
    }

    override var acceptsFirstResponder: Bool {
         return true
    }

    func prepareBeginnerGame(sender: NSMenuItem) {
        Swift.print("beginner")
        fieldDimensions = NSSize(width: 9, height: 9)
        numberOfMines = 10
        (self.dataSource as! FieldDataSource).resetGame()
        reloadData()
    }

    func prepareAdvancedGame(sender: NSMenuItem) {
        Swift.print("advanced")
        fieldDimensions = NSSize(width: 16, height: 16)
        numberOfMines = 40
        Swift.print(self.dataSource)
        (self.dataSource as! FieldDataSource).resetGame()
        reloadData()
    }

    func resetGame(sender: NSMenuItem) {
        (self.dataSource as! FieldDataSource).resetGame()
        reloadData()
    }

}

extension FieldCollectionView: FieldSettingsProvider {

    func getFieldSize() -> NSSize {
        return fieldDimensions ?? NSSize(width: 0, height: 0)
    }

    func getNumberOfMines() -> Int {
        return numberOfMines
    }

}
