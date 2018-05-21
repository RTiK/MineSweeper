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
    var timer: Timer!

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: self.tick)
    }

    func stop() {
        timer.invalidate()
    }

    func tick(_ timer:Timer) {
        counter += 1
        if counter == 999 {
            stop()  // you fell asleep
        }
    }

    func reset() {
        counter = 0
    }
}
