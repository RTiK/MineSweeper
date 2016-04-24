//
//  ViewController.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 23/04/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var fieldCollectionView: NSCollectionView! {
        didSet {
            Swift.print("asdf")
            fieldCollectionView.registerNib(NSNib(nibNamed: "CellCollectionViewItem", bundle: nil), forItemWithIdentifier: "CellItem")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
            Swift.print(representedObject)
        // Update the view, if already loaded.
        }
    }

}

class UnscrollableView: NSScrollView {
    override func scrollWheel(theEvent: NSEvent) {
        // disables scrolling
    }
}

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        window?.styleMask = (self.window?.styleMask)! | NSFullSizeContentViewWindowMask
        window?.titlebarAppearsTransparent = true
        window?.movableByWindowBackground = true
        //window?.setContentSize(NSSize(width: 300, height: 300))
    }
}

class CellColors {
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