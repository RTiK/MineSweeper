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
        registerNib(NSNib(nibNamed: "CellCollectionViewItem", bundle: nil), forItemWithIdentifier: "cellItem")
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.fieldCollectionView = self

        setGameParams(NSSize(width: 9, height: 9), mines: 10)
        resetGame(self)
    }

    override var acceptsFirstResponder: Bool {
         return true
    }

    func prepareBeginnerGame(sender: NSMenuItem) {
        setGameParams(NSSize(width: 9, height: 9), mines: 10)
        resetGame(sender)
    }

    func prepareIntermediateGame(sender: NSMenuItem) {
        setGameParams(NSSize(width: 16, height: 16), mines: 40)
        resetGame(sender)
    }

    func prepareExpertGame(sender: NSMenuItem) {
        setGameParams(NSSize(width: 30, height: 16), mines: 99)
        resetGame(sender)
    }

    private func setGameParams(size: NSSize, mines: Int) {
        fieldDimensions = size
        numberOfMines = mines
    }

    func resetGame(sender: AnyObject) {
        window?.windowController?.showWindow(self)
        collectionViewLayout?.prepareLayout()
        (self.dataSource as! FieldDataSource).resetGame()
        reloadData()
        window?.setContentSize(NSSize(
            width: (collectionViewLayout?.collectionViewContentSize)!.width + 2,
            height: (collectionViewLayout?.collectionViewContentSize)!.height + 68))
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
