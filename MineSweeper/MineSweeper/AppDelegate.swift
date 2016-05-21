//
//  AppDelegate.swift
//  MineSweeper
//
//  Created by Artem Khatchatourov on 27/04/16.
//  Copyright © 2016 rt. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //var windowController: WindowController?
    var fieldCollectionView: FieldCollectionView?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // in case the game window has been closed the actions from the menu will be caught
    // here these methods will instantiate a new window and pass the field size to it
    func prepareBeginnerGame(sender: NSMenuItem) {
        fieldCollectionView?.prepareBeginnerGame(sender)
    }

    func prepareIntermediateGame(sender: NSMenuItem) {
        fieldCollectionView?.prepareIntermediateGame(sender)
    }
    
    func prepareExpertGame(sender: NSMenuItem) {
        fieldCollectionView?.prepareExpertGame(sender)
    }
}

class WindowController: NSWindowController {
    override func awakeFromNib() {
        super.awakeFromNib()
        window?.titlebarAppearsTransparent = true
    }
}