//
//  FieldDataSource.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 06/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class FieldDataSource: NSObject {
    
    var dataArray = [Int](count: 16 * 16, repeatedValue: 0)
    var firstMove = false
    var width: Int!, height: Int!
    dynamic var minesLeftCounter = 0
    dynamic var gameOver = false

    var cellsToRefresh = Set<NSIndexPath>()
    var incorrectCells = Set<Int>()

    @IBOutlet weak var fieldCollectionView: FieldCollectionView!
    @IBOutlet weak var timerLabel: TimerTextField!

    func resetGame() {
        let fieldSize = fieldCollectionView.getFieldSize()
        width = Int(fieldSize.width)
        height = Int(fieldSize.height)
        let numberOfMines = fieldCollectionView.getNumberOfMines()
        dataArray = [Int](count: Int(width * height), repeatedValue: 0)
        placeMines(numberOfMines)
        minesLeftCounter = numberOfMines
        incorrectCells.removeAll()
        timerLabel.reset()
        firstMove = true
        gameOver = false
    }

    private func placeMines(numberOfMInes: Int) {
        for _ in 1 ... numberOfMInes {
            placeMineAtRandom()
        }
    }

    private func placeMineAtRandom() {
        var randomIndex = Int(arc4random()) % (dataArray.count)
        while dataArray[randomIndex] != CellProperties.TYPE_EMPTY {
            randomIndex = Int(arc4random()) % (dataArray.count)
        }
        dataArray[randomIndex] = CellProperties.TYPE_MINE
    }

    private func resolveIncorrect() {
        cellsToRefresh = Set<NSIndexPath>()
        for cell in incorrectCells {
            //dataArray[cell] = CellProperties.TYPE_MINE_FLAG
            cellsToRefresh.insert(NSIndexPath(forItem: cell, inSection: 0))
        }
        fieldCollectionView.reloadItemsAtIndexPaths(cellsToRefresh)
    }

    private func resolveAll() {
        resolveIncorrect()
        for cellIndex in 0 ... dataArray.count-1 {
            if dataArray[cellIndex] == CellProperties.TYPE_EMPTY {
                let numOfMines = countMines(cellIndex)
                if numOfMines > 0 {
                    dataArray[cellIndex] = numOfMines
                } else if numOfMines == 0 {
                    dataArray[cellIndex] = CellProperties.TYPE_VISITED
                }
                cellsToRefresh.insert(NSIndexPath(forItem: cellIndex, inSection: 0))
            }
        }
        fieldCollectionView.reloadItemsAtIndexPaths(cellsToRefresh)
    }

    func markMine(cellAtIndex: Int) {
        let currentCell = dataArray[cellAtIndex]
        if currentCell == CellProperties.TYPE_EMPTY {
            dataArray[cellAtIndex] = CellProperties.TYPE_EMPTY_FLAG
            minesLeftCounter -= 1
            incorrectCells.insert(cellAtIndex)
        } else if currentCell == CellProperties.TYPE_EMPTY_FLAG {
            dataArray[cellAtIndex] = CellProperties.TYPE_EMPTY_QUESTION
            minesLeftCounter += 1
        } else if currentCell == CellProperties.TYPE_EMPTY_QUESTION {
            dataArray[cellAtIndex] = CellProperties.TYPE_EMPTY
            incorrectCells.remove(cellAtIndex)
        } else if currentCell == CellProperties.TYPE_MINE {
            dataArray[cellAtIndex] = CellProperties.TYPE_MINE_FLAG
            minesLeftCounter -= 1
        } else if currentCell == CellProperties.TYPE_MINE_FLAG {
            dataArray[cellAtIndex] = CellProperties.TYPE_MINE_QUESTION
            minesLeftCounter += 1
            incorrectCells.insert(cellAtIndex)
        } else if currentCell == CellProperties.TYPE_MINE_QUESTION {
            dataArray[cellAtIndex] = CellProperties.TYPE_MINE
            incorrectCells.remove(cellAtIndex)
        }
        if isSolved() {
            timerLabel.stop()
            resolveAll()
        }
        fieldCollectionView.reloadItemsAtIndexPaths(Set<NSIndexPath>(arrayLiteral: NSIndexPath(forItem: cellAtIndex, inSection: 0)))
    }

    func uncover(cellWithIndex: Int) {
        cellsToRefresh = Set<NSIndexPath>()

        let currentCell = dataArray[cellWithIndex]
        if firstMove {
            if currentCell == CellProperties.TYPE_MINE {
                dataArray[cellWithIndex] = CellProperties.TYPE_EMPTY    // a mine should not be uncovered on first click
                placeMineAtRandom()                                     // it should be moved to a random free position instead
            }
            timerLabel.start()
            firstMove = false
            cascade(cellWithIndex)
        } else if (currentCell == CellProperties.TYPE_MINE) {
            timerLabel.stop()
            resolveIncorrect()
            gameOver = true
            dataArray[cellWithIndex] = CellProperties.TYPE_MINE_EXPLODED
            fieldCollectionView.reloadData()
        } else if (currentCell == CellProperties.TYPE_EMPTY) {
            cascade(cellWithIndex)
        }
        if isSolved() {
            timerLabel.stop()
            resolveAll()
        }
        fieldCollectionView.reloadItemsAtIndexPaths(cellsToRefresh)
    }

    private func isSolved() -> Bool {
        return minesLeftCounter == 0 && incorrectCells.isEmpty
    }

    private func countMines(atIndex: Int) -> Int {
        var mineCount = 0
        if canGoNorth(atIndex) {
            if dataArray[atIndex-width] == CellProperties.TYPE_MINE
                || dataArray[atIndex-width] == CellProperties.TYPE_MINE_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray[atIndex-(width-1)] == CellProperties.TYPE_MINE
                    || dataArray[atIndex-(width-1)] == CellProperties.TYPE_MINE_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray[atIndex-(width+1)] == CellProperties.TYPE_MINE
                    || dataArray[atIndex-(width+1)] == CellProperties.TYPE_MINE_FLAG) {
                mineCount += 1
            }
        }
        if canGoSouth(atIndex) {
            if dataArray[atIndex+width] == CellProperties.TYPE_MINE
                || dataArray[atIndex+width] == CellProperties.TYPE_MINE_FLAG {
                mineCount += 1
            }
            if canGoEast(atIndex)
                && (dataArray[atIndex+(width+1)] == CellProperties.TYPE_MINE
                    || dataArray[atIndex+(width+1)] == CellProperties.TYPE_MINE_FLAG) {
                mineCount += 1
            }
            if canGoWest(atIndex)
                && (dataArray[atIndex+(width-1)] == CellProperties.TYPE_MINE
                    || dataArray[atIndex+(width-1)] == CellProperties.TYPE_MINE_FLAG) {
                mineCount += 1
            }
        }
        if canGoEast(atIndex)
            && (dataArray[atIndex+1] == CellProperties.TYPE_MINE
                || dataArray[atIndex+1] == CellProperties.TYPE_MINE_FLAG) {
            mineCount += 1
        }
        if canGoWest(atIndex)
            && (dataArray[atIndex-1] == CellProperties.TYPE_MINE
                || dataArray[atIndex-1] == CellProperties.TYPE_MINE_FLAG) {
            mineCount += 1
        }
        return mineCount
    }

    private func cascade(fromIndex: Int) {
        if dataArray[fromIndex] == CellProperties.TYPE_VISITED || dataArray[fromIndex] > 0 {
            return
        }

        let mineCount = countMines(fromIndex)
        // Set visited
        if mineCount == 0 {
            dataArray[fromIndex] = CellProperties.TYPE_VISITED
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

    private func canGoWest(fromIndex: Int) -> Bool {
        return fromIndex % width > 0
    }

    private func canGoEast(fromIndex:Int) -> Bool {
        return fromIndex % width < (width - 1)
    }

    private func canGoNorth(fromIndex: Int) -> Bool {
        return fromIndex > width - 1
    }

    private func canGoSouth(fromIndex: Int) -> Bool {
        return fromIndex < (width * (height - 1))
    }
}

extension FieldDataSource: NSCollectionViewDataSource {

    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier("cellItem", forIndexPath: indexPath) as! CellCollectionViewItem
        item.dataSource = self
        item.index = indexPath.indexAtPosition(1)
        item.disabled = gameOver
        if dataArray.count > 0 {
            item.representedObject = dataArray[indexPath.indexAtPosition(1)]
        }
        return item
    }

    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

}
