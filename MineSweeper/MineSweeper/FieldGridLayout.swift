//
//  FieldGridLayout.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 06/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import  Cocoa

class FieldGridLayout: NSCollectionViewGridLayout {
    var gapBetweenItems = 1
    var layoutAttributes = [NSCollectionViewLayoutAttributes]()
    var contentSize: NSSize!
    var oldFieldSize = NSSize(width: 0, height: 0)

    override func prepare() {
        let fieldSize = (collectionView as! FieldCollectionView).getFieldSize()
        if fieldSize == oldFieldSize {
            return  // field dimensions have not changed, do not recalculate
        }
        oldFieldSize = fieldSize
        let fieldWidth = Int(fieldSize.width)
        let fieldHeight = Int(fieldSize.height)
        let viewWidth = fieldWidth * CellProperties.CELL_WIDTH + (fieldWidth - 1) * gapBetweenItems
        let viewHeight = fieldHeight * CellProperties.CELL_HEIGHT + (fieldHeight - 1) * gapBetweenItems

        let horizontalItemOffset = CellProperties.CELL_WIDTH + gapBetweenItems
        let verticalItemOffset = CellProperties.CELL_HEIGHT + gapBetweenItems
        let numberOfItems = fieldWidth * fieldHeight

        if numberOfItems > 0 {
            contentSize = NSSize(width: viewWidth, height: viewHeight)
            layoutAttributes = [NSCollectionViewLayoutAttributes]()
            for i in 0 ... numberOfItems-1 {    // calculate position of each cell
                let attribute = NSCollectionViewLayoutAttributes(forItemWith: IndexPath(item: i, section: 0))
                let column = i % fieldWidth
                let row = i / fieldWidth
                attribute.frame = NSRect(
                    x: horizontalItemOffset * column, y: verticalItemOffset*row,
                    width: CellProperties.CELL_WIDTH, height: CellProperties.CELL_HEIGHT)
                layoutAttributes.append(attribute)
            }
        }
    }

    override var collectionViewContentSize: NSSize {
        if contentSize == nil {
            prepare()
        }
        return contentSize
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return self.layoutAttributes[indexPath[1]]
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return layoutAttributes
    }
    
}
