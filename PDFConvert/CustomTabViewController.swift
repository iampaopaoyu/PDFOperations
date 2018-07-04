//
//  CustomTabViewController.swift
//  PDFOperations
//
//  Created by Steven Kanceruk on 1/7/18.
//  Copyright © 2018 steve. All rights reserved.
//

import Cocoa

class CustomTabViewController: NSTabViewController {

    @IBOutlet weak var theTabView: NSTabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //self.theTabView.centerXAnchor += 60
        // self.tabView.alignmentRectInsets.top = 60
        //self.tabView.frame = CGRect( x: 0, y: 200, width: 320, height: 50)
    }
    
    override func viewDidLayout() {
        //self.tabView.frame = CGRect( x: 0, y: -100, width: 600, height: 300)
        //self.theTabView.frame  = CGRect( x: 0, y: -100, width: 600, height: 300)
        //self.theTabView.frame.
        self.tabView.bounds.insetBy(dx: 0, dy: -300)
        // self.tabView.controlSize = .
            //.frame.origin.y -= 100
    }
}
