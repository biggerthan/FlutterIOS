//
//  AppDelegate.swift
//  flutter-ios-mix
//
//  Created by liu on 2019/4/29.
//  Copyright © 2019 liu. All rights reserved.
//

import UIKit
import Flutter
@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    
    var _lifeCycle:FlutterPluginAppLifeCycleDelegate!
    override init() {
        super.init()
        _lifeCycle = FlutterPluginAppLifeCycleDelegate()
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return _lifeCycle.application(application, didFinishLaunchingWithOptions: launchOptions ?? [:])
    }

}

