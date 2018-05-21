//
//  FieldCollectionView.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 06/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class FieldCollectionView: NSCollectionView {

    fileprivate var fieldDimensions = NSSize(width: 1, height: 1)
    fileprivate var numberOfMines = 0

    override func awakeFromNib() {
        register(NSNib(nibNamed: NSNib.Name(rawValue: "CellCollectionViewItem"), bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cellItem"))
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.fieldCollectionView = self

        fieldDimensions = NSSize(width: 9, height: 9)
        numberOfMines = 10
        resetGame(self)
    }

    override var acceptsFirstResponder: Bool {
         return true
    }

    func prepareBeginnerGame(_ sender: NSMenuItem) {
        setGameParams(NSSize(width: 9, height: 9), mines: 10)
        resetGame(sender)
    }

    func prepareIntermediateGame(_ sender: NSMenuItem) {
        setGameParams(NSSize(width: 16, height: 16), mines: 40)
        resetGame(sender)
    }

    func prepareExpertGame(_ sender: NSMenuItem) {
        setGameParams(NSSize(width: 30, height: 16), mines: 99)
        resetGame(sender)
    }

    private func setGameParams(_ size: NSSize, mines: Int) {
        fieldDimensions = size
        numberOfMines = mines
    }

    @IBAction func reset(button: NSButton) {
        resetGame(button)
    }

    func resetGame(_ sender: AnyObject) {
        collectionViewLayout?.prepare()
        (self.dataSource as! FieldDataSource).resetGame()
        reloadData()
        window?.setContentSize(NSSize(
            width: (collectionViewLayout?.collectionViewContentSize)!.width + 2,
            height: (collectionViewLayout?.collectionViewContentSize)!.height + 68))
        window?.windowController?.showWindow(self)  // in case the window has been closed
    }

} 

extension FieldCollectionView: FieldSettingsProvider {

    func getFieldSize() -> NSSize {
        return fieldDimensions
    }

    func getNumberOfMines() -> Int {
        return numberOfMines
    }

}
