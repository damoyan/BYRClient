//
//  AppDelegate.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/26/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setupUI()
        AppSharedInfo.sharedInstance
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        if let tab = application.keyWindow?.rootViewController as? UITabBarController, navi = tab.selectedViewController as? UINavigationController {
////            navi.popToRootViewControllerAnimated(<#animated: Bool#>)
//        }
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 10)), dispatch_get_main_queue()) {
//        dispatch_async(dispatch_get_main_queue()) {
//            println("tabbar")
//            tabbar.selectedIndex = 0
//        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func setupUI() {
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(UIColor(rgb: 0x3b8ede), side: 1), forBarMetrics: .Default)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "navi_back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "navi_back")
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(18)]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
}

