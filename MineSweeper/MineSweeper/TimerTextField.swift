//
//  TimerTextField.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 08/05/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class TimerTextField: NSTextField {
    var counter: Int = 0 {
        didSet {
            stringValue = String(counter)
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