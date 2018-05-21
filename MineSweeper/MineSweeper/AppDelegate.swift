//
//  AppDelegate.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 27/04/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSResponder, NSApplicationDelegate {

    //var windowController: WindowController?
    var fieldCollectionView: FieldCollectionView?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // in case the game window has been closed the actions from the menu will be caught
    // here, these methods will instantiate a new window
    @IBAction func prepareBeginnerGame(_ sender: NSMenuItem) {
        fieldCollectionView?.prepareBeginnerGame(sender)
    }

    @IBAction func prepareIntermediateGame(_ sender: NSMenuItem) {
        fieldCollectionView?.prepareIntermediateGame(sender)
    }
    
    @IBAction func prepareExpertGame(_ sender: NSMenuItem) {
        fieldCollectionView?.prepareExpertGame(sender)
    }

    @IBAction func resetGame(_ sender: NSMenuItem) {
        fieldCollectionView?.resetGame(sender)
    }
}

class WindowController: NSWindowController {
    override func awakeFromNib() {
        super.awakeFromNib()
        window?.titlebarAppearsTransparent = true
    }
}
