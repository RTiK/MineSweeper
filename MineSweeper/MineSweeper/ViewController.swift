//
//  ViewController.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 27/04/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.setBoundsSize(NSSize(width: 418, height: 420))
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

class DataSource: NSObject, NSCollectionViewDataSource {
    var height = 0, width = 0
    var dataArray = [Int]()
    var firstMove = false
    dynamic var minesLeftCounter = 0
    dynamic var gameOver = false

    var cellsToRefresh = Set<NSIndexPath>()

    @IBOutlet weak var timerLabel: TimerLabel!

    @IBOutlet weak var fieldCollectionView: NSCollectionView! {
        didSet {
            fieldCollectionView.registerNib(NSNib(nibNamed: "CellItem", bundle: nil), forItemWithIdentifier: "cellItem")
        }
    }

    @IBAction func startButtonPressed(sender: NSButton) {
        startGame()
        print("game started")
        gameOver = false
        fieldCollectionView.reloadData()
    }

    func startGame() {
        width = 16
        height = 16
        dataArray = [Int](count: width*height, repeatedValue: 0)
        placeMines(40)
        minesLeftCounter = 40
        timerLabel.reset()
        timerLabel.start()
        firstMove = true
    }

    func placeMines(numberOfMInes: Int) {
        for _ in 1 ... numberOfMInes {
            placeMineAtRandom()
        }
    }

    func placeMineAtRandom() {
        var randomIndex = Int(arc4random()) % (dataArray.count)
        while dataArray[randomIndex] != CellType.EMPTY {
            randomIndex = Int(arc4random()) % (dataArray.count)
        }
        dataArray[randomIndex] = CellType.MINE
    }

    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier("cellItem", forIndexPath: indexPath) as! CollectionViewItem
        item.dataSource = self
        item.index = indexPath.indexAtPosition(1)
        item.representedObject = dataArray[indexPath.indexAtPosition(1)]
        return item
    }

    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    func uncover(cellWithIndex: Int) -> Bool {
        cellsToRefresh = Set<NSIndexPath>()

        let currentCell = dataArray[cellWithIndex]
        if (currentCell == CellType.MINE) {
            if firstMove {
                dataArray[cellWithIndex] = CellType.EMPTY   // a mine should not be uncovered on first click
                placeMineAtRandom()                         // it should be moved to a random free position
            } else {
                timerLabel.stop()
                print("GAME OVER")  // TODO: Put game over here
                return true
            }
        } else if (currentCell == CellType.EMPTY) {
            cascade(cellWithIndex)
        }
        fieldCollectionView.reloadItemsAtIndexPaths(cellsToRefresh)
        firstMove = false
        return false
    }

    func countMines(atIndex: Int) -> Int {
        var mineCount = 0
        if canGoNorth(atIndex) {
            if dataArray[atIndex-width] == CellType.MINE
                || dataArray[atIndex-width] == CellType.RIGHT_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray[atIndex-(width-1)] == CellType.MINE
                    || dataArray[atIndex-(width-1)] == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray[atIndex-(width+1)] == CellType.MINE
                    || dataArray[atIndex-(width+1)] == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
        }
        if canGoSouth(atIndex) {
            if dataArray[atIndex+width] == CellType.MINE
                || dataArray[atIndex+width] == CellType.RIGHT_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray[atIndex+(width+1)] == CellType.MINE
                    || dataArray[atIndex+(width+1)] == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray[atIndex+(width-1)] == CellType.MINE
                    || dataArray[atIndex+(width-1)] == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
        }
        if canGoEast(atIndex)
            && (dataArray[atIndex+1] == CellType.MINE
                || dataArray[atIndex+1] == CellType.RIGHT_FLAG) {
            mineCount += 1
        }
        if canGoWest(atIndex)
            && (dataArray[atIndex-1] == CellType.MINE
                || dataArray[atIndex-1] == CellType.RIGHT_FLAG) {
            mineCount += 1
        }
        return mineCount
    }

    func cascade(fromIndex: Int) {
        if dataArray[fromIndex] == CellType.VISITED
            || dataArray[fromIndex] > 0 {
            return
        }

        let mineCount = countMines(fromIndex)
        // Set visited
        if mineCount == 0 {
            dataArray[fromIndex] = CellType.VISITED
            if canGoNorth(fromIndex) {
                cascade(fromIndex-width)
                if canGoEast(fromIndex) {
                    cascade(fromIndex-(width-1))
                }
                if canGoWest(fromIndex) {
                    cascade(fromIndex-(width+1))
                }
            }
            if canGoSouth(fromIndex) {
                cascade(fromIndex+width)
                if canGoEast(fromIndex) {
                    cascade(fromIndex+(width+1))
                }
                if canGoWest(fromIndex) {
                    cascade(fromIndex+(width-1))
                }
            }
            if canGoEast(fromIndex) {
                cascade(fromIndex+1)
            }
            if canGoWest(fromIndex) {
                cascade(fromIndex-1)
            }
        } else {
            dataArray[fromIndex] = mineCount
        }
        cellsToRefresh.insert(NSIndexPath(forItem: fromIndex, inSection: 0))

    }

    func canGoWest(fromIndex: Int) -> Bool {
        return fromIndex % width > 0
    }

    func canGoEast(fromIndex:Int) -> Bool {
        return fromIndex % width < (width-1)
    }

    func canGoNorth(fromIndex: Int) -> Bool {
        return fromIndex > width - 1
    }

    func canGoSouth(fromIndex: Int) -> Bool {
        return fromIndex < (width*(height-1))
    }

    func mineSet(atIndex: Int) {

        let currentCell = dataArray[atIndex]
        if currentCell == CellType.EMPTY {
            dataArray[atIndex] = CellType.WRONG_FLAG
            minesLeftCounter -= 1
        } else if currentCell == CellType.MINE {
            dataArray[atIndex] = CellType.RIGHT_FLAG
            minesLeftCounter += 1
        } else if currentCell == CellType.RIGHT_FLAG {
            dataArray[atIndex] = CellType.MINE
            minesLeftCounter -= 1
        } else if currentCell == CellType.WRONG_FLAG {
            dataArray[atIndex] = CellType.EMPTY
            minesLeftCounter += 1
        }
        fieldCollectionView.reloadItemsAtIndexPaths(Set<NSIndexPath>(arrayLiteral: NSIndexPath(forItem: atIndex, inSection: 0)))
    }
}

class CollectionViewItem: NSCollectionViewItem {

    var dataSource: DataSource!
    var index: Int!

    override var representedObject: AnyObject? {
        didSet {
            if representedObject != nil {
                view.wantsLayer = true
                let cellType = representedObject as! Int
                if cellType > 0 {
                    textField?.stringValue = String(cellType)
                    view.layer?.backgroundColor = CellColor.CELL_DARK.CGColor
                } else if cellType == CellType.EMPTY {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColor.CELL_EMPTY.CGColor
                } else if cellType == CellType.VISITED {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColor.CELL_LIGHT.CGColor
                } else if cellType == CellType.RIGHT_FLAG || cellType == CellType.WRONG_FLAG {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColor.MINE_LIGHT.CGColor
                } else if cellType == CellType.MINE {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColor.CELL_EMPTY.CGColor
                }

            }
        }
    }

    override func mouseUp(theEvent: NSEvent) {
        let gameOver = dataSource.uncover(index)
        if gameOver {
            view.layer?.backgroundColor = CellColor.MINE_DARK.CGColor
        }
    }

    override func rightMouseUp(theEvent: NSEvent) {
        dataSource.mineSet(index)
    }
}

class TimerLabel: NSTextField {
    var counter = 0
    var timer: NSTimer!

    func start() {
        Swift.print("timer started")    // TODO
        timer = NSTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }

    func stop() {
        timer.invalidate()
    }

    func tick() {
        Swift.print("counter")
        counter += 1
        stringValue = "Time: " + String(counter)
    }

    func reset() {
        counter = 0
    }
}

class CellColor {
    static let MINE_LIGHT = NSColor(red: 1.0, green: 0.28, blue: 0.27, alpha: 1.0)  // 0xFF4746
    static let MINE_DARK = NSColor(red: 0.70, green: 0.13, blue: 0.12, alpha: 1.0)  // 0xB2201F
    static let CELL_EMPTY = NSColor(red: 1.0, green: 0.99, blue: 0.38, alpha: 1.0)  // 0xFFFD60
    static let CELL_LIGHT = NSColor(red: 0.14, green: 0.54, blue: 0.80, alpha: 1.0) // 0x248ACC
    static let CELL_DARK = NSColor(red: 0.16, green: 0.49, blue: 0.70, alpha: 1.0)  // 0x287DB2
}

class CellType {
    static let EMPTY: Int = 0
    static let MINE: Int = -1
    static let VISITED: Int = -2
    static let RIGHT_FLAG: Int = -3
    static let WRONG_FLAG: Int = -4
}