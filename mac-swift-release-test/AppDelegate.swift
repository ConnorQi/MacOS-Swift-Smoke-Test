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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CrashesDelegate, CLLocationManagerDelegate {

   var locationManager: CLLocationManager = CLLocationManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Crashes.delegate = self
        
        
        AppCenter.start(withAppSecret: "be361901-5ebb-454b-860d-7bae3fcfecba", services:[
            Analytics.self,
            Crashes.self,
            ])
        Crashes.userConfirmationHandler = ({ (errorReports: [ErrorReport]) in
            let alert: NSAlert = NSAlert()
            alert.messageText = "Sorry about that!"
            alert.informativeText = "Do you want to send an anonymous crash report so we can fix the issue?"
            alert.addButton(withTitle: "Always send")
            alert.addButton(withTitle: "Send")
            alert.addButton(withTitle: "Don't send")
            
            switch (alert.runModal()) {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                Crashes.notify(with: .always)
                break;
            case NSApplication.ModalResponse.alertSecondButtonReturn:
                Crashes.notify(with: .send)
                break;
            case NSApplication.ModalResponse.alertThirdButtonReturn:
                Crashes.notify(with: .dontSend)
                break;
            default:
                break;
            }
            return true
        })
        
     
        // Set loglevel to verbose.
        AppCenter.logLevel = .verbose
        
        AppCenter.logUrl = "https://in-integration.dev.avalanch.es"
        
        // Set location manager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // Crashes Delegate
    func crashes(_ crashes: Crashes, shouldProcess errorReport: ErrorReport) -> Bool {
        if errorReport.exceptionReason != nil {
            NSLog("Should process error report with: %@", errorReport.exceptionReason);
        }
        return true
    }
    
    func crashes(_ crashes: Crashes, willSend errorReport: ErrorReport) {
        if errorReport.exceptionReason != nil {
            NSLog("Will send error report with: %@", errorReport.exceptionReason);
        }
    }
    
    func crashes(_ crashes: Crashes, didSucceedSending errorReport: ErrorReport) {
        if errorReport.exceptionReason != nil {
            NSLog("Did succeed error report sending with: %@", errorReport.exceptionReason);
        }
    }
    
    func crashes(_ crashes: Crashes, didFailSending errorReport: ErrorReport, withError error: Error?) {
        if errorReport.exceptionReason != nil {
            NSLog("Did fail sending report with: %@, and error: %@", errorReport.exceptionReason, error?.localizedDescription ?? "");
        }
    }
    
    func attachments(with crashes: Crashes, for errorReport: ErrorReport) -> [ErrorAttachmentLog]? {
        let attachment1 = ErrorAttachmentLog.attachment(withText: "\(Host.current().localizedName ?? "")", filename: "hello.txt")
        let attachment2 = ErrorAttachmentLog.attachment(withBinary: "Fake image".data(using: String.Encoding.utf8), filename: nil, contentType: "image/jpeg")
        return [attachment1!, attachment2!]
    }
    
    // CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let userLocation:CLLocation = locations[0] as CLLocation
        CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if error == nil {
                AppCenter.countryCode = placemarks?.first?.isoCountryCode ?? ""
            }
        }
    }
    
    func locationManager(_ Manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
