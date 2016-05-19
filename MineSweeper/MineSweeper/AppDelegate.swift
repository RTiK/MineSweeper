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

    func prepareAdvancedGame(sender: NSMenuItem) {
        WindowController()
        // TODO make new window if the old one has been closed
    }

}

class WindowController: NSWindowController {
    override func awakeFromNib() {
        super.awakeFromNib()
        window?.titlebarAppearsTransparent = true
    }
}