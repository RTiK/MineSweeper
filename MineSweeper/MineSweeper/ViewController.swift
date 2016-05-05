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
    @IBOutlet var dataSource: DataSource!
    @IBOutlet weak var collectionView: NSCollectionView!

    @IBAction func newBeginnerGame(sender: NSMenuItem) {
        dataSource.initGame(9, fieldHeight: 9, numberOfMines: 9)
    }

    @IBAction func newAdvancedGame(sender: NSMenuItem) {
        dataSource.initGame(16, fieldHeight: 16, numberOfMines: 40)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.setBoundsSize(NSSize(width: 418, height: 420))
        // Do any additional setup after loading the view.
        print("view loaded")
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

class DataSource: NSObject, NSCollectionViewDataSource {
    var height: Int = 9
    var width: Int = 9
    var mines = 10
    var dataArray = [Int](count: 81, repeatedValue: 0)
    var firstMove = false
    dynamic var minesLeftCounter = 0
    dynamic var gameOver = false

    var cellsToRefresh = Set<NSIndexPath>()
    var incorrectCells = Set<Int>()

    @IBOutlet weak var timerLabel: TimerLabel!

    @IBOutlet weak var fieldCollectionView: NSCollectionView! {
        didSet {
            fieldCollectionView.registerNib(NSNib(nibNamed: "CellItem", bundle: nil), forItemWithIdentifier: "cellItem")
            fieldCollectionView.collectionViewLayout = FieldGridLayout(numOfRows: height, numOfColumns: width, itemDimension: NSSize(width: 25, height: 25), gapBetweenItems: 1)
            print("layout set")
        }
    }

    @IBAction func makeAdvancedField(sender: NSButton) {
        initGame(16, fieldHeight: 16, numberOfMines: 40)
    }

    @IBAction func startButtonPressed(sender: NSButton) {
        resetGame()
        print("game started")
        gameOver = false
        fieldCollectionView.reloadData()
    }

    func resetGame() {
        dataArray = [Int](count: width*height, repeatedValue: 0)
        placeMines(mines)
        minesLeftCounter = mines
        timerLabel.reset()
        firstMove = true
    }

    func initGame(fieldWidth: Int, fieldHeight: Int, numberOfMines: Int) {
        width = fieldWidth
        height = fieldHeight
        mines = numberOfMines
        dataArray = [Int](count: width*height, repeatedValue: 0)
        fieldCollectionView.collectionViewLayout = FieldGridLayout(numOfRows: height, numOfColumns: width, itemDimension: NSSize(width: 25, height: 25), gapBetweenItems: 1)
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
        if dataArray.count > 0 {
            item.representedObject = dataArray[indexPath.indexAtPosition(1)]
        }
        return item
    }

    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("items in section", dataArray.count)
        return dataArray.count
    }

    func resolveIncorrect() {
        cellsToRefresh = Set<NSIndexPath>()
        for cell in incorrectCells {
            dataArray[cell] = CellType.MINE_FLAG
            cellsToRefresh.insert(NSIndexPath(forItem: cell, inSection: 0))
        }
        fieldCollectionView.reloadItemsAtIndexPaths(cellsToRefresh)
    }

    func markMine(cellAtIndex: Int) {
        let currentCell = dataArray[cellAtIndex]
        if currentCell == CellType.EMPTY {
            dataArray[cellAtIndex] = CellType.EMPTY_FLAG
            minesLeftCounter -= 1
            incorrectCells.insert(cellAtIndex)
        } else if currentCell == CellType.EMPTY_FLAG {
            dataArray[cellAtIndex] = CellType.EMPTY_QUESTION
            minesLeftCounter += 1
        } else if currentCell == CellType.EMPTY_QUESTION {
            dataArray[cellAtIndex] = CellType.EMPTY
            incorrectCells.remove(cellAtIndex)
        } else if currentCell == CellType.MINE {
            dataArray[cellAtIndex] = CellType.MINE_FLAG
            minesLeftCounter -= 1
        } else if currentCell == CellType.MINE_FLAG {
            dataArray[cellAtIndex] = CellType.MINE_QUESTION
            minesLeftCounter += 1
            incorrectCells.insert(cellAtIndex)
        } else if currentCell == CellType.MINE_QUESTION {
            dataArray[cellAtIndex] = CellType.MINE
            incorrectCells.remove(cellAtIndex)
        }
        fieldCollectionView.reloadItemsAtIndexPaths(Set<NSIndexPath>(arrayLiteral: NSIndexPath(forItem: cellAtIndex, inSection: 0)))
    }

    func uncover(cellWithIndex: Int) -> Bool {
        cellsToRefresh = Set<NSIndexPath>()

        let currentCell = dataArray[cellWithIndex]
        if firstMove {
            if currentCell == CellType.MINE {
                dataArray[cellWithIndex] = CellType.EMPTY   // a mine should not be uncovered on first click
                placeMineAtRandom()                         // it should be moved to a random free position
            }
            timerLabel.start()
            firstMove = false
            cascade(cellWithIndex)
        } else if (currentCell == CellType.MINE) {
            timerLabel.stop()
            resolveIncorrect()
            print("GAME OVER")  // TODO: Put game over here
            return true
        } else if (currentCell == CellType.EMPTY) {
            cascade(cellWithIndex)
        }
        fieldCollectionView.reloadItemsAtIndexPaths(cellsToRefresh)
        return false
    }

    func countMines(atIndex: Int) -> Int {
        var mineCount = 0
        if canGoNorth(atIndex) {
            if dataArray[atIndex-width] == CellType.MINE
                || dataArray[atIndex-width] == CellType.MINE_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray[atIndex-(width-1)] == CellType.MINE
                    || dataArray[atIndex-(width-1)] == CellType.MINE_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray[atIndex-(width+1)] == CellType.MINE
                    || dataArray[atIndex-(width+1)] == CellType.MINE_FLAG) {
                mineCount += 1
            }
        }
        if canGoSouth(atIndex) {
            if dataArray[atIndex+width] == CellType.MINE
                || dataArray[atIndex+width] == CellType.MINE_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray[atIndex+(width+1)] == CellType.MINE
                    || dataArray[atIndex+(width+1)] == CellType.MINE_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray[atIndex+(width-1)] == CellType.MINE
                    || dataArray[atIndex+(width-1)] == CellType.MINE_FLAG) {
                mineCount += 1
            }
        }
        if canGoEast(atIndex)
            && (dataArray[atIndex+1] == CellType.MINE
                || dataArray[atIndex+1] == CellType.MINE_FLAG) {
            mineCount += 1
        }
        if canGoWest(atIndex)
            && (dataArray[atIndex-1] == CellType.MINE
                || dataArray[atIndex-1] == CellType.MINE_FLAG) {
            mineCount += 1
        }
        return mineCount
    }

    func cascade(fromIndex: Int) {
        if dataArray[fromIndex] == CellType.VISITED || dataArray[fromIndex] > 0 {
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
}

class CollectionViewItem: NSCollectionViewItem {

    var dataSource: DataSource!
    var index: Int!

    override var representedObject: AnyObject? {
        didSet {
            print("object set to ", representedObject)
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
                } else if cellType == CellType.MINE_FLAG || cellType == CellType.EMPTY_FLAG {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColor.MINE_MEDUIM.CGColor
                } else if cellType == CellType.MINE {
                    textField?.stringValue = ""
                    view.layer?.backgroundColor = CellColor.CELL_EMPTY.CGColor
                } else if (cellType == CellType.EMPTY_QUESTION || cellType == CellType.MINE_QUESTION) {
                    textField?.stringValue = "?"
                    view.layer?.backgroundColor = CellColor.CELL_GREEN.CGColor
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
        dataSource.markMine(index)
    }
}

class FieldGridLayout: NSCollectionViewGridLayout {

    let itemWidth: Int
    let itemHeight: Int
    let gap: Int
    var viewWidth: Int!
    var viewHeight: Int!
    var layoutAttributes = [NSCollectionViewLayoutAttributes]()
    var contentSize: NSSize!

    init(numOfRows: Int, numOfColumns: Int, itemDimension: NSSize, gapBetweenItems: Int) {
        itemWidth = Int(itemDimension.width)
        itemHeight = Int(itemDimension.height)
        gap = gapBetweenItems
        super.init()
        maximumNumberOfRows = numOfRows
        maximumNumberOfColumns = numOfColumns
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareLayout() {
        viewWidth = maximumNumberOfColumns * itemWidth + (maximumNumberOfColumns - 1) * gap
        viewHeight = maximumNumberOfRows * itemHeight + (maximumNumberOfRows - 1) * gap
        contentSize = NSSize(width: viewWidth, height: viewHeight)

        let horizontalItemOffset = itemWidth + gap
        let verticalItemOffset = itemHeight + gap
        let numberOfItems = maximumNumberOfColumns * maximumNumberOfRows
        for i in 0 ... numberOfItems-1 {
            let attribute = NSCollectionViewLayoutAttributes(forItemWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
            let row = i % maximumNumberOfColumns
            let column = i / maximumNumberOfColumns
            attribute.frame = NSRect(x: horizontalItemOffset * column, y: verticalItemOffset*row, width: itemWidth, height: itemHeight)
            layoutAttributes.append(attribute)
        }
    }

    override var collectionViewContentSize: NSSize {
        return contentSize
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> NSCollectionViewLayoutAttributes? {
        print("asked for item at ", indexPath)
        for attr in layoutAttributes {
            if attr.indexPath == indexPath {
                return attr
            }
        }
        print("returning nil")
        return nil
    }

    override func layoutAttributesForElementsInRect(rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return layoutAttributes
    }

}

class TimerLabel: NSTextField {
    var counter: Int = 0 {
        didSet {
            stringValue = "Time: " + String(counter)
        }
    }
    var timer: NSTimer!

    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
    }

    func stop() {
        timer.invalidate()
    }

    func tick() {
        counter += 1
    }

    func reset() {
        counter = 0
    }
}

class CellColor {
    static let MINE_LIGHT = NSColor(red: 1.0, green: 0.38, blue: 0.37, alpha: 1.0)
    static let MINE_MEDUIM = NSColor(red: 1.0, green: 0.28, blue: 0.27, alpha: 1.0)  // 0xFF4746
    static let MINE_DARK = NSColor(red: 0.70, green: 0.13, blue: 0.12, alpha: 1.0)  // 0xB2201F
    static let CELL_EMPTY = NSColor(red: 1.0, green: 0.99, blue: 0.38, alpha: 1.0)  // 0xFFFD60
    static let CELL_LIGHT = NSColor(red: 0.14, green: 0.54, blue: 0.80, alpha: 1.0) // 0x248ACC
    static let CELL_DARK = NSColor(red: 0.16, green: 0.49, blue: 0.70, alpha: 1.0)  // 0x287DB2
    static let CELL_GREEN = NSColor(red: 0.5, green: 0.99, blue: 0.38, alpha: 1.0)
}

class CellType {
    static let EMPTY: Int = 0
    static let MINE: Int = -1
    static let VISITED: Int = -2
    static let MINE_FLAG: Int = -3
    static let EMPTY_FLAG: Int = -4
    static let MINE_QUESTION: Int = -5
    static let EMPTY_QUESTION: Int = -6
}