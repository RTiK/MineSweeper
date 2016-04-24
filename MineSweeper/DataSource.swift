//
//  DataSource.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 23/04/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class DataSource: NSObject, NSCollectionViewDataSource {
    var width = 16, height = 16, numOfMines = 40
    var dataArray = NSMutableArray(array: [Int](count: 256, repeatedValue: 0))
    dynamic var minesLeftCounter = 0
    var firstMove = true

    @IBAction func startGame(sender: NSButton) {
        dataArray = NSMutableArray(array: [Int](count: width * height, repeatedValue: 0))
        placeMines(numOfMines)
        fieldCollectionView.reloadData()
        minesLeftCounter = numOfMines
        firstMove = true
        printData()
    }

    func makeGame(width: Int, height: Int, numOfMines: Int) {
        self.width = width
        self.height = height
        self.numOfMines = numOfMines
    }

    @IBOutlet weak var fieldCollectionView: NSCollectionView!

    func placeMines(numberOfMInes: Int) {
        for _ in 1 ... numberOfMInes {
            placeMineAtRandom()
        }
    }

    func placeMineAtRandom() {
        var randomIndex = Int(arc4random()) % (dataArray.count)
        while dataArray.objectAtIndex(randomIndex) as! Int != CellType.EMPTY {
            randomIndex = Int(arc4random()) % (dataArray.count)
        }
        dataArray[randomIndex] = CellType.MINE
    }

    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        Swift.print(dataArray.count)
        return dataArray.count
    }

    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier("CellItem", forIndexPath: indexPath) as! CellCollectionViewItem
        item.representedObject = dataArray.objectAtIndex(indexPath.indexAtPosition(1))
        item.index = indexPath.indexAtPosition(1)
        item.dataSource = self
        return item
    }

    func uncover(cellWithIndex: Int) -> Bool {
        if dataArray.objectAtIndex(cellWithIndex) as! Int == CellType.MINE {
            if firstMove {
                dataArray[cellWithIndex] = CellType.EMPTY   // a mine cannot me uncovered on first click
                placeMineAtRandom() // it should be moved to a random position
            } else {
                Swift.print("Game over")
                return true
            }
        }
        cascade(cellWithIndex)
        firstMove = false
        fieldCollectionView.reloadData()
        printData()
        return false
    }

    func countMines(atIndex: Int) -> Int {
        var mineCount = 0
        if canGoNorth(atIndex) {
            if dataArray.objectAtIndex(atIndex-width) as! Int == CellType.MINE
                || dataArray.objectAtIndex(atIndex-width) as! Int == CellType.RIGHT_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray.objectAtIndex(atIndex-(width-1)) as! Int == CellType.MINE
                    || dataArray.objectAtIndex(atIndex-(width-1)) as! Int == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray.objectAtIndex(atIndex-(width+1)) as! Int == CellType.MINE
                    || dataArray.objectAtIndex(atIndex-(width+1)) as! Int == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
        }
        if canGoSouth(atIndex) {
            if dataArray.objectAtIndex(atIndex+width) as! Int == CellType.MINE
                || dataArray.objectAtIndex(atIndex+width) as! Int == CellType.RIGHT_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray.objectAtIndex(atIndex+(width+1)) as! Int == CellType.MINE
                    || dataArray.objectAtIndex(atIndex+(width+1)) as! Int == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray.objectAtIndex(atIndex+(width-1)) as! Int == CellType.MINE
                    || dataArray.objectAtIndex(atIndex+(width-1)) as! Int == CellType.RIGHT_FLAG) {
                mineCount += 1
            }
        }
        if canGoEast(atIndex)
            && (dataArray.objectAtIndex(atIndex+1) as! Int == CellType.MINE
                || dataArray.objectAtIndex(atIndex+1) as! Int == CellType.RIGHT_FLAG) {
            mineCount += 1
        }
        if canGoWest(atIndex)
            && (dataArray.objectAtIndex(atIndex-1) as! Int == CellType.MINE
                || dataArray.objectAtIndex(atIndex-1) as! Int == CellType.RIGHT_FLAG) {
            mineCount += 1
        }
        return mineCount
    }

    func cascade(fromIndex: Int) {
        if dataArray.objectAtIndex(fromIndex) as! Int == CellType.VISITED
            || dataArray.objectAtIndex(fromIndex) as! Int > 0 {
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

    }

    func canGoWest(fromIndex: Int) -> Bool {
        return fromIndex % width > 0
    }

    func canGoEast(fromIndex:Int) -> Bool {
        return fromIndex % width < (width-1)
    }

    func canGoNorth(fromIndex: Int) -> Bool {
        return fromIndex > (width*1)
    }

    func canGoSouth(fromIndex: Int) -> Bool {
        return fromIndex < (width*(height-1))
    }

    func mineSet(atIndex: Int) {
        switch dataArray.objectAtIndex(atIndex) as! Int {
        case CellType.MINE:
            minesLeftCounter -= 1
            dataArray[atIndex] = CellType.RIGHT_FLAG
        case CellType.RIGHT_FLAG:
            minesLeftCounter += 1
            dataArray[atIndex] = CellType.MINE
        case CellType.WRONG_FLAG:
            minesLeftCounter += 1
            dataArray[atIndex] = CellType.EMPTY
        default:
            minesLeftCounter -= 1
            dataArray[atIndex] = CellType.WRONG_FLAG
        }
        fieldCollectionView.reloadData()
    }

    func printData() {
        for i in 0 ... (height-1) {
            //print(dataArray[i*(height-1) ... i*(height-1)+(width-1)])
        }
    }
}
