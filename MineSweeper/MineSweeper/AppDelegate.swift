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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // in case the game window has been closed the actions from the menu will caught here
    // these methods will instantiate a new window and pass the field size to it
    func prepareBeginnerGame(sender: NSMenuItem) {
        // TODO make new window if the old one has been closed
    }

    func prepareIntermediateGame(sender: NSMenuItem) {
        
    }
    
    func prepareExpertGame(sender: NSMenuItem) {
        
    }

}

class WindowController: NSWindowController {
    override func awakeFromNib() {
        super.awakeFromNib()
        window?.titlebarAppearsTransparent = true
    }
}