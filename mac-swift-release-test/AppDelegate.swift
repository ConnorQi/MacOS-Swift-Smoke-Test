//
//  AppDelegate.swift
//  mac-swift-release-test
//
//  Created by bys on 2019/8/27.
//  Copyright © 2019 bys. All rights reserved.
//

import Cocoa
import CoreLocation

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterPush

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MSCrashesDelegate, MSPushDelegate, CLLocationManagerDelegate {

   var locationManager: CLLocationManager = CLLocationManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        MSCrashes.setDelegate(self);
        // Push Delegate.
        MSPush.setDelegate(self);
        
        MSAppCenter.start("a2b7200a-d4a5-478d-babd-ddc075c602dc", withServices:[
            MSAnalytics.self,
            MSCrashes.self,
            MSPush.self
            ])
        MSAppCenter.setLogUrl("https://in-integration.dev.avalanch.es");
        MSCrashes.setUserConfirmationHandler({ (errorReports: [MSErrorReport]) in
            let alert: NSAlert = NSAlert()
            alert.messageText = "Sorry about that!"
            alert.informativeText = "Do you want to send an anonymous crash report so we can fix the issue?"
            alert.addButton(withTitle: "Always send")
            alert.addButton(withTitle: "Send")
            alert.addButton(withTitle: "Don't send")
            
            switch (alert.runModal()) {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                MSCrashes.notify(with: .always)
                break;
            case NSApplication.ModalResponse.alertSecondButtonReturn:
                MSCrashes.notify(with: .send)
                break;
            case NSApplication.ModalResponse.alertThirdButtonReturn:
                MSCrashes.notify(with: .dontSend)
                break;
            default:
                break;
            }
            return true
        })
        
     
        // Set loglevel to verbose.
        MSAppCenter.setLogLevel(MSLogLevel.verbose)
        
        // Set location manager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // Crashes Delegate
    
    func crashes(_ crashes: MSCrashes!, shouldProcessErrorReport errorReport: MSErrorReport!) -> Bool {
        if errorReport.exceptionReason != nil {
            NSLog("Should process error report with: %@", errorReport.exceptionReason);
        }
        return true
    }
    
    func crashes(_ crashes: MSCrashes!, willSend errorReport: MSErrorReport!) {
        if errorReport.exceptionReason != nil {
            NSLog("Will send error report with: %@", errorReport.exceptionReason);
        }
    }
    
    func crashes(_ crashes: MSCrashes!, didSucceedSending errorReport: MSErrorReport!) {
        if errorReport.exceptionReason != nil {
            NSLog("Did succeed error report sending with: %@", errorReport.exceptionReason);
        }
    }
    
    func crashes(_ crashes: MSCrashes!, didFailSending errorReport: MSErrorReport!, withError error: Error!) {
        if errorReport.exceptionReason != nil {
            NSLog("Did fail sending report with: %@, and error: %@", errorReport.exceptionReason, error.localizedDescription);
        }
    }
    
    func attachments(with crashes: MSCrashes, for errorReport: MSErrorReport) -> [MSErrorAttachmentLog] {
        let attachment1 = MSErrorAttachmentLog.attachment(withText: "Hello world!", filename: "hello.txt")
        let attachment2 = MSErrorAttachmentLog.attachment(withBinary: "Fake image".data(using: String.Encoding.utf8), filename: nil, contentType: "image/jpeg")
        return [attachment1!, attachment2!]
    }

    func push(_ push: MSPush!, didReceive pushNotification: MSPushNotification!) {
        let title: String = pushNotification.title ?? ""
        var message: String = pushNotification.message ?? ""
        var customData: String = ""
        for item in pushNotification.customData {
            customData =  ((customData.isEmpty) ? "" : "\(customData), ") + "\(item.key): \(item.value)"
        }
        message =  message + ((customData.isEmpty) ? "" : "\n\(customData)")
        let alert: NSAlert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    // CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let userLocation:CLLocation = locations[0] as CLLocation
        CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if error == nil {
                MSAppCenter.setCountryCode(placemarks?.first?.isoCountryCode)
            }
        }
    }
    
    func locationManager(_ Manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

