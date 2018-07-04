//
//  AppDelegate.swift
//  PDFConvert
//
//  Created by Steven Kanceruk on 11/29/17.
//  Copyright © 2017 steve. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
 
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    /*
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            for window in sender.windows {
                if (window.delegate?.isKind(of: ViewController.self)) == true {
                    window.makeKeyAndOrderFront(self)
                }
            }
        }
        return true
    }
    
    func applicationShouldHandleReopen(theApplication: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window: AnyObject in theApplication.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
    */
}

