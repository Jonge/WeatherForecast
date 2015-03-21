//
//  AppDelegate.swift
//  WeatherForecast
//
//  Created by David Jongepier on 09.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configureAppearance()
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        DataManager.sharedManager.selectedLocation = DataManager.sharedManager.currentLocation
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

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        DataManager.sharedManager.locationManager.startUpdatingLocation()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private struct Appearance {
        static let TintColor        = UIColor(red: 47/255.0, green: 145/255.0, blue: 255/255.0, alpha: 1.0)
        static let DarkColor        = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
        
        static let RegularFontName  = "ProximaNova-Regular"
        static let SemiboldFontName = "ProximaNova-Semibold"
        static let BoldFontName     = "ProximaNova-Bold"
        static let LightFontName    = "ProximaNova-Light"
    }
    
    private func configureAppearance() {
        window?.tintColor = Appearance.TintColor
        
        // Tab bar items
        let tabBarItemFont = UIFont(name: Appearance.SemiboldFontName, size: 10.0)!
        let tabBarItemFontDictionary = NSDictionary(
            objects: [
                tabBarItemFont,
                Appearance.DarkColor
            ],
            forKeys: [
                NSFontAttributeName,
                NSForegroundColorAttributeName
            ]
        )
        let tabBarItemSelectedFontDictionary = NSDictionary(object: Appearance.TintColor, forKey: NSForegroundColorAttributeName)
        UITabBarItem.appearance().setTitleTextAttributes(tabBarItemFontDictionary, forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes(tabBarItemSelectedFontDictionary, forState: .Selected)
        
        // Navigation bar
        let navigationTitleFont = UIFont(name: Appearance.SemiboldFontName, size: 18.0)!
        let navigationBarTitleAttributes = NSDictionary(object: navigationTitleFont, forKey: NSFontAttributeName)
        UINavigationBar.appearance().titleTextAttributes = navigationBarTitleAttributes
        
        let navigationBarBackground = UIImage(named: "White")
        let shadowImage = UIImage(named: "Line")
        UINavigationBar.appearance().setBackgroundImage(navigationBarBackground, forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = shadowImage
        
        // Bar items
        let barItemFont = UIFont(name: Appearance.SemiboldFontName, size: 16.0)!
        let barItemFontDictionary = NSDictionary(object: barItemFont, forKey: NSFontAttributeName)
        UIBarButtonItem.appearance().setTitleTextAttributes(barItemFontDictionary, forState: .Normal)
        
        // Search bar
        let searchBarBackground = UIImage(named: "Input")?.resizableImageWithCapInsets(UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0))
        let searchBarIcon = UIImage(named: "Search")
        let searchBarClearIcon = UIImage(named: "Clear")
        UISearchBar.appearance().setSearchFieldBackgroundImage(searchBarBackground, forState: .Normal)
        UISearchBar.appearance().setImage(searchBarIcon, forSearchBarIcon: .Search, state: .Normal)
        UISearchBar.appearance().setImage(searchBarClearIcon, forSearchBarIcon: .Clear, state: .Normal)
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 5.0, vertical: 1.0)
        
        let searchBarFont = UIFont(name: Appearance.RegularFontName, size: 16.0)!
        
        // Swift doesn't support appearanceWhenContainedIn:, we must use an Obj-C class
        ConfigureAppearance.configureSearchBarWithTextColor(Appearance.TintColor, font: searchBarFont)
    }

}

