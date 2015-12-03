//
//  AppDelegate.swift
//  HiBro
//
//  Created by Dealjava on 12/1/15.
//  Copyright © 2015 dealjava. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    private var xmppSetup = xmppClientAppDelegate.sharedInstance
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSUserDefaults.standardUserDefaults().setObject("ios@localhost", forKey: "userID")
        NSUserDefaults.standardUserDefaults().setObject("1234", forKey: "userPassword")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        xmppSetup.disconnect()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        xmppSetup.connect()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

}

