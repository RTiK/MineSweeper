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
        fieldDimensions = NSSize(width: 9, height: 9)
        numberOfMines = 10
        resetGame(sender)
    }

    func prepareAdvancedGame(sender: NSMenuItem) {
        fieldDimensions = NSSize(width: 16, height: 16)
        numberOfMines = 40
        resetGame(sender)
    }

    func resetGame(sender: NSMenuItem) {
        (self.dataSource as! FieldDataSource).resetGame()
        reloadData()
        Swift.print(collectionViewLayout?.collectionViewContentSize)
        //superview?.setBoundsSize((collectionViewLayout?.collectionViewContentSize)!)
        Swift.print(superview?.bounds)
        //let windowWidth = (collectionViewLayout?.collectionViewContentSize.width)! + 2
        //let windowHeight = (collectionViewLayout?.collectionViewContentSize.height)! + 62
        //setBoundsSize((collectionViewLayout?.collectionViewContentSize)!)
        //window?.setContentSize(NSSize(width: windowWidth, height: windowHeight))
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
