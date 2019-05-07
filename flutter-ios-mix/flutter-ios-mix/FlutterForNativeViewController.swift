//
//  FlutterForNativeViewController.swift
//  flutter-ios-mix
//
//  Created by liu on 2019/4/30.
//  Copyright © 2019 liu. All rights reserved.
//

import UIKit
import Flutter
import MBProgressHUD
class FlutterForNativeViewController: FlutterViewController, FlutterStreamHandler {
    
    let methodChannelForFlutter = "MethodChannelForFlutter"
    let eventChannelForFlutter = "EventChannelForFlutter"
    // 统一, flutter不知道自己是怎么出来的
    let dismissKey = "FlutterForNativeViewControllerDismissKey"
    
    var allowChannel = true
    
    var pageInFlutter = "" {
        didSet {
            if pageInFlutter.isEmpty {
                return
            }
            setInitialRoute(pageInFlutter)
        }
    }
    
    class func buildWithEngine(engine: FlutterEngine? = nil) -> FlutterForNativeViewController {
        return FlutterForNativeViewController(engine: engine, nibName: nil, bundle: nil)
    }
    
    class func buildWithProject(project: FlutterDartProject? = nil) -> FlutterForNativeViewController {
        return FlutterForNativeViewController(project: project, nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if allowChannel {
            methodForFlutter()
            eventForFlutter()
        }
        let a = MBProgressHUD.showAdded(to: view, animated: true)
        a?.hide(true, afterDelay: 2)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            [weak self] in
            guard let slf = self else {return}
            slf.dismiss(animated: true, completion: nil)
        }
    }
    
    override var splashScreenView: UIView! {
        set {
            
        }
        
        get {
            
            let v = UIView(frame: UIScreen.main.bounds)
            v.backgroundColor = UIColor.yellow
            return v
        }
    }
    
    private func methodForFlutter() {
        // 1. ---------------------
        // flutter调用原生方法
        // 原生使用methodChannel注册方法去响应
        // 触发是在flutter里面触发
        // flutter中对应代码
        // import 'package:flutter/services.dart';
        // static const methodChannel = const MethodChannel("MethodChannelForFlutter");
        // 参数种类可以是简单字符串, 可以是序列化字符串
        // methodChannel.invokeMethod(dismissKey, "参数")
        let channel = FlutterMethodChannel(name: methodChannelForFlutter, binaryMessenger: self)
        channel.setMethodCallHandler {
            [weak self] (call, result) in
            guard let slf = self else {return}
            print("flutter传过来的参数: \(some: call.arguments)")
            if call.method == slf.dismissKey {
                // 根据需求, 添加参数
                if slf.presentingViewController == nil {
                    slf.popSelf()
                    result("执行了pop")
                }else {
                    slf.dismissSelf()
                    result("执行了dimiss")
                }
            }else {
                result("什么都没做")
            }
        }
    }
    
    private func eventForFlutter() {
        // 2. ---------------------
        // 原生调用flutter方法
        // 原生使用evenChannal注册方法, flutter去响应
        // 触发是在原生里面触发
        let event = FlutterEventChannel(name: eventChannelForFlutter, binaryMessenger: self)
        // 设置代理
        weak var wSelf = self
        event.setStreamHandler(wSelf)
        // flutter中对应代码
        // import 'package:flutter/services.dart';
        // static const eventChannel = const EventChannel('EventChannelForFlutter');
        
        // 这功能有啥必要??? 暂时不知道? MethodChannel完全可以做到?
        // MethodChannel和EventChannel功能太像了
    }
    
    private func dismissSelf(animated: Bool = true, completion: (()->())? = nil) {
        dismiss(animated: animated, completion: completion)
    }
    
    private func popSelf(_ count: Int = 1) {
        if var vcs = navigationController?.viewControllers {
            let start = vcs.count-count
            let end = vcs.count-1
            vcs.removeSubrange(start...end)
            navigationController?.setViewControllers(vcs, animated: true)
        }
    }
    
    // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("arguments: \(some: arguments)")
        events("这里有给flutter的东西")
        return nil
    }
    
    // flutter不再接收
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    deinit {
        print("never invoked")
    }

}
