//
//  ViewController.swift
//  mac-swift-release-test
//
//  Created by bys on 2019/8/27.
//  Copyright © 2019 bys. All rights reserved.
//

import Cocoa
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func event(_ sender: NSButton) {
        Analytics.trackEvent("\(Host.current().localizedName ?? "")")
    }
    
    
    @IBAction func eventwithproperties(_ sender: NSButton) {
        Analytics.trackEvent("\(Host.current().localizedName ?? "") with properties",
                             withProperties:
                                ["Category" : "Music",
                                 "FileName" : "favorite.avi"])
    }
    
    @IBAction func crash(_ sender: NSButton) {
        Crashes.generateTestCrash()
    }
}

