//
//  FieldDataSource.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 06/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class FieldDataSource: NSObject {
    
    var dataArray = [Int](repeating: 0, count: 16 * 16)
    var firstMove = false
    var width: Int!, height: Int!
    var minesLeftCounter = 0
    var gameOver = false

    var cellsToRefresh = Set<IndexPath>()
    var incorrectCells = Set<Int>()

    @IBOutlet weak var fieldCollectionView: FieldCollectionView!
    @IBOutlet weak var timerLabel: TimerTextField!
    @IBOutlet weak var minesLeftLabel: NSTextField!
    @IBOutlet weak var resetButton: NSButton!

    func resetGame() {
        let fieldSize = fieldCollectionView.getFieldSize()
        width = Int(fieldSize.width)
        height = Int(fieldSize.height)
        let numberOfMines = fieldCollectionView.getNumberOfMines()
        dataArray = [Int](repeating: 0, count: Int(width * height))
        placeMines(numberOfMines)
        minesLeftCounter = numberOfMines
        incorrectCells.removeAll()
        //timerLabel.reset()
        firstMove = true
        gameOver = false
        //resetButton.title = "Reset"
    }

    private func placeMines(_ numberOfMInes: Int) {
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
        cellsToRefresh = Set<IndexPath>()
        for cell in incorrectCells {
            cellsToRefresh.insert(IndexPath(item: cell, section: 0))
        }
        fieldCollectionView.reloadItems(at: cellsToRefresh)
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
                cellsToRefresh.insert(IndexPath(item: cellIndex, section: 0))
            }
        }
        fieldCollectionView.reloadItems(at: cellsToRefresh)
    }

    func markMine(_ cellAtIndex: Int) {
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
            //gameOver = true
            //resetButton.title = "Play Again"
        }
        fieldCollectionView.reloadItems(at: Set<IndexPath>(arrayLiteral: IndexPath(item: cellAtIndex, section: 0)))
        minesLeftLabel.stringValue = String(minesLeftCounter)
    }

    func uncover(_ cellWithIndex: Int) {
        cellsToRefresh = Set<IndexPath>()

        let currentCell = dataArray[cellWithIndex]
        if firstMove {
            if currentCell == CellProperties.TYPE_MINE {
                dataArray[cellWithIndex] = CellProperties.TYPE_EMPTY    // a mine should not be uncovered on first click
                placeMineAtRandom()                                     // it should be moved to a random free position instead
            }
            //timerLabel.start()
            firstMove = false
            cascade(cellWithIndex, &cellsToRefresh)
        } else if (currentCell == CellProperties.TYPE_MINE) {
            //timerLabel.stop()
            resolveIncorrect()
            gameOver = true
            dataArray[cellWithIndex] = CellProperties.TYPE_MINE_EXPLODED
            fieldCollectionView.reloadData()
        } else if (currentCell == CellProperties.TYPE_EMPTY) {
            cascade(cellWithIndex, &cellsToRefresh)
        }
        if isSolved() {
            //timerLabel.stop()
            resolveAll()
            //gameOver = true
            resetButton.title = "Play Again"
        }
        fieldCollectionView.reloadItems(at: cellsToRefresh)
        minesLeftLabel.stringValue = String(minesLeftCounter)
    }

    func uncoverNeighborsOf(_ cellWithIndex: Int) {
        if dataArray[cellWithIndex] == CellProperties.TYPE_MINE_FLAG || dataArray[cellWithIndex] == CellProperties.TYPE_MINE_QUESTION {
            return
        }
        var minesSurrounding = 0
        if canGoNorth(cellWithIndex) {
            if dataArray[cellWithIndex - width] == CellProperties.TYPE_MINE_FLAG {
                minesSurrounding += 1
            }
            if canGoEast(cellWithIndex)
                && dataArray[cellWithIndex - (width - 1)] == CellProperties.TYPE_MINE_FLAG {
                minesSurrounding += 1
            }
            if canGoWest(cellWithIndex)
                && dataArray[cellWithIndex - (width + 1)] == CellProperties.TYPE_MINE_FLAG {
                minesSurrounding += 1
            }
        }
        if canGoSouth(cellWithIndex) {
            if dataArray[cellWithIndex + width ] == CellProperties.TYPE_MINE_FLAG {
                minesSurrounding += 1
            }
            if canGoEast(cellWithIndex+(width+1))
                && dataArray[cellWithIndex+(width+1)] == CellProperties.TYPE_MINE_FLAG {
                minesSurrounding += 1
            }
            if canGoWest(cellWithIndex+(width-1))
                && dataArray[cellWithIndex+(width-1)] == CellProperties.TYPE_MINE_FLAG {
                minesSurrounding += 1
            }
        }
        if canGoEast(cellWithIndex)
            && dataArray[cellWithIndex+1] == CellProperties.TYPE_MINE_FLAG {
            minesSurrounding += 1
        }
        if canGoWest(cellWithIndex)
            && dataArray[cellWithIndex-1] == CellProperties.TYPE_MINE_FLAG {
            minesSurrounding += 1
        }
        if minesSurrounding >= dataArray[cellWithIndex] {
            if canGoNorth(cellWithIndex) {
                uncover(cellWithIndex - width)
                if canGoEast(cellWithIndex) {
                    uncover(cellWithIndex - (width - 1))
                }
                if canGoWest(cellWithIndex) {
                    uncover(cellWithIndex - (width + 1))
                }
            }
            if canGoSouth(cellWithIndex) {
                uncover(cellWithIndex + width)
                if canGoEast(cellWithIndex) {
                    uncover(cellWithIndex + (width + 1))
                }
                if canGoWest(cellWithIndex) {
                    uncover(cellWithIndex + (width - 1))
                }
            }
            if canGoEast(cellWithIndex) {
                uncover(cellWithIndex + 1)
            }
            if canGoWest(cellWithIndex) {
                uncover(cellWithIndex - 1)
            }
        }
    }

    private func isSolved() -> Bool {
        return minesLeftCounter == 0 && incorrectCells.isEmpty
    }

    private func countMines(_ atIndex: Int) -> Int {
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

    private func cascade(_ fromIndex: Int, _ cellsToRefresh: inout Set<IndexPath>) {
        if dataArray[fromIndex] != 0 {
            return
        }
//        if dataArray[fromIndex] == CellProperties.TYPE_VISITED || dataArray[fromIndex] > 0 {
//            return
//        }

        let mineCount = countMines(fromIndex)
        // Set visited
        if mineCount == 0 {
            dataArray[fromIndex] = CellProperties.TYPE_VISITED
            if canGoNorth(fromIndex) {
                cascade(fromIndex-width, &cellsToRefresh)
                if canGoEast(fromIndex) {
                    cascade(fromIndex-(width-1), &cellsToRefresh)
                }
                if canGoWest(fromIndex) {
                    cascade(fromIndex-(width+1), &cellsToRefresh)
                }
            }
            if canGoSouth(fromIndex) {
                cascade(fromIndex+width, &cellsToRefresh)
                if canGoEast(fromIndex) {
                    cascade(fromIndex+(width+1), &cellsToRefresh)
                }
                if canGoWest(fromIndex) {
                    cascade(fromIndex+(width-1), &cellsToRefresh)
                }
            }
            if canGoEast(fromIndex) {
                cascade(fromIndex+1, &cellsToRefresh)
            }
            if canGoWest(fromIndex) {
                cascade(fromIndex-1, &cellsToRefresh)
            }
        } else {
            dataArray[fromIndex] = mineCount
        }
        cellsToRefresh.insert(IndexPath(item: fromIndex, section: 0))

    }

    private func canGoWest(_ fromIndex: Int) -> Bool {
        return fromIndex % width > 0
    }

    private func canGoEast(_ fromIndex:Int) -> Bool {
        return fromIndex % width < (width - 1)
    }

    private func canGoNorth(_ fromIndex: Int) -> Bool {
        return fromIndex > width - 1
    }

    private func canGoSouth(_ fromIndex: Int) -> Bool { 
        return fromIndex < (width * (height - 1))
    }
}

extension FieldDataSource: NSCollectionViewDataSource {

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cellItem"), for: indexPath) as! CellCollectionViewItem
        item.value = dataArray[indexPath[1]]
        item.dataSource = self
        item.index = indexPath[1]
        item.disabled = gameOver
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

}
