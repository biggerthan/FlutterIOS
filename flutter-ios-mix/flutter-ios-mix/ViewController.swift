//
//  ViewController.swift
//  flutter-ios-mix
//
//  Created by liu on 2019/4/29.
//  Copyright © 2019 liu. All rights reserved.
//

import UIKit
import Flutter
import MBProgressHUD
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let a = MBProgressHUD.showAdded(to: view, animated: true)
        a?.hide(true, afterDelay: 2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let flutterVC = FlutterForNativeViewController.buildWithProject()
        flutterVC.pageInFlutter = "test"
        present(flutterVC, animated: true, completion: nil)
//        navigationController?.pushViewController(flutterVC, animated: true)
    }
    
}

extension String.StringInterpolation {
    mutating func appendInterpolation(some: Any?) {
        appendInterpolation(some == nil ? "nil":some!)
//        appendInterpolation(String(describing: some))
    }
}
