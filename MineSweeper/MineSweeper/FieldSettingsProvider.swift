//
//  FieldSizeProvider.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 06/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Foundation

protocol FieldSettingsProvider {
    func getFieldSize() -> NSSize
    func getNumberOfMines() -> Int
}