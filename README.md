# FlutterIOS
Flutter IOS mix

Flutter ios混编, 自己看的教程, 然后记录一下, 并记录一些未解决问题

   具体教程看: 
    
    https://juejin.im/entry/5c20fdf6e51d4522ec59fc7f
    https://juejin.im/post/5bb033515188255c5e66f500

   基本常量:
   
    导航栏高度
    MediaQuery.of(context).padding.top
    屏幕size
    MediaQuery.of(context).size.width

* 新建ios项目
- 项目:  /Users/liu/Flutter/FlutterIOSMix/flutter-ios-mix/flutter-ios-mix.xcodeproj
* 在项目同级目录下创建flutter_module
flutter create -t module flutter_module
- 添加三个.xcconfig文件, 文件内容是引用关系
指定 config 文件，Debug 对应 Debug，Release 对应 Release
* 添加flutter脚本, 脚本需要注释一行, 引入脚本产物
- 最后改造Appdelegate
* 关于pod部分
![image](https://github.com/biggerthan/FlutterIOS/blob/master/WX20190506-110726%402x.png)

Swift使用是import Flutter  
然后直接使用FlutterViewController, 可以被继承作为主页  
FlutterViewController就是Flutter的载体

   关于页面一一对应, 需要改造main.dart
   
   ```Dart
    import 'package:flutter/material.dart';
    import 'test.dart';
    import 'dart:ui' as ui;
    // ui.window.defaultRouteName是Native端初始化时传来的route
    void main() => runApp(_widgetForRoute(ui.window.defaultRouteName));
    // 根据route跳转不同界面
    Widget _widgetForRoute(String route) {
      Widget widget;
      print('route: $route');
      switch (route) {
        case 'test':
        widget = TestPage(title: 'Flutter Demo Test Page');
        break;
      default:
        widget = MyHomePage(title: 'Flutter Demo Home Page');
        break;
      }
      // 页面必须是用MaterialApp包住, 否则报错
      return MaterialApp(home: widget,);
    }
   ```
    
   不同于flutter新建的项目中的main.dart, 入口不一样
   ```Dart
    // 不同于flutter项目, main的入口是MyApp
    // 原生调用flutter, 需要设置上述路由, 来指定页面跳转
    // void main() => runApp(MyApp());
    // class MyApp extends StatelessWidget {
    //   // This widget is the root of your application.
    //   @override
    //   Widget build(BuildContext context) {
    //     return MaterialApp(
    //       title: 'Flutter Demo',
    //       home: MyHomePage(title: 'Flutter Demo Home Page'),
    //     );
    //   }
    // }
   ```
    
    
   关于交互
   ```Swift
    //
    //  ViewController.swift
    //  flutter-ios-mix
    //
    //  Created by liu on 2019/4/29.
    //  Copyright © 2019 liu. All rights reserved.
    //
    import UIKit
    import Flutter
    class ViewController: UIViewController, FlutterStreamHandler {
        override func viewDidLoad() {
            super.viewDidLoad()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let vc = FlutterViewController(project: nil, nibName: nil, bundle: nil) {
            // 设置路由
            vc.setInitialRoute("test")
            
            // 1. ---------------------
            // flutter调用原生方法
            // 原生使用methodChannel注册方法去响应
            // 触发是在flutter里面触发
            let channel = FlutterMethodChannel(name: "MethodChannelName", binaryMessenger: vc)
            channel.setMethodCallHandler { (call, result) in
                print("flutter传过来的参数: \(call.arguments ?? "no arguments")")
                if call.method == "method1" {
                    vc.dismiss(animated: true, completion: nil)
                }else {
                    
                }
                result("告诉flutter方法已经执行, 并且传回参数")
            }
            // flutter中对应代码
            // import 'package:flutter/services.dart';
            // static const methodChannel = const MethodChannel("MethodChannelName");
            // 参数种类可以是简单字符串, 可以是序列化字符串
            // methodChannel.invokeMethod("method1", "参数")
            
            
            // 2. ---------------------
            // 原生调用flutter方法
            // 原生使用evenChannal注册方法, flutter去响应
            // 触发是在原生里面触发
            let event = FlutterEventChannel(name: "EventChannelName", binaryMessenger: vc)
            // 设置代理
            event.setStreamHandler(self)
            // flutter中对应代码
            // import 'package:flutter/services.dart';
            // static const eventChannel = const EventChannel('EventChannelName');
            // 但是我不大懂, 这有什么用呢????
            present(vc, animated: true, completion: nil)
        }
    }
    
    // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("asdhas")
        print("arguments: \(arguments)")
        events("有什么用?")
        return nil
    }
    
    // flutter不再接收
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
}
```

关于其他细节
   
    FlutterViewController是flutter渲染页面的基础, 继承自UIViewController,
    push的时候, 会带有native导航栏, 所以push的FlutterViewController需要考虑选择native的还是flutter导航栏
    另外, FlutterViewController的view是铺满屏幕的, 所以需要控制显示区域(MediaQuery.of(context).padding)
    上面的问题就会涉及到, 根据present或者push, 选择是否显示导航栏,
    根据机型(x或者普通)来控制安全区域, 所以会有在初始化一个FlutterViewController传参的问题

目前抽出FlutterForNativeViewController, 包含不完善的互相调用接口

   另外还有一些问题:
   
    1. native deinit方法不走, flutter里面的dispose不走(下面提及的内存问题)  
    2. push或者present的时候先显示启动页, 重写splashScreenView也不起作用  
    
   关于执行程序
   
    启动程序, 需要是xcode执行, 如果在flutter端执行启动, 一些注册的交互会识别不到, 报错崩溃
    
    cd工程目录(包含ios和android文件夹的共同目录中, lib中是代码文件)
    执行flutter attach, 会在xcode控制台, 打印出flutter中的log
    目前没发现hot reload有什么用, 不知道是不是姿势问题
 
    然后就是文末出现的内存问题, 打开flutter页面就不会内存会暴涨, 并且不会下降, 会一直涨
    还有FlutterPlatformView内存泄漏问题, flutter中使用原生view时导致的,
    具体看这三个链接, 期待后续Google自己解决问题
    链接中给出的方法是, 自己编译framework, 修改原码
    https://juejin.im/post/5c24acd5f265da6164141236
    https://juejin.im/post/5c6e6dd5f265da2dcf62821f
    https://juejin.im/post/5c24ad306fb9a049d2361cff
    再说!!!
