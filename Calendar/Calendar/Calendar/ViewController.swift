//
//  ViewController.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var test:TestView! = TestView();
    override func viewDidLoad() {
        super.viewDidLoad()
        var avd = PYCalendarView()
        avd.frame = CGRectMake(0, 30, 320, 320)
        self.view.addSubview(avd)
        avd.backgroundColor = UIColor.clearColor()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillLayoutSubviews() {
        self.test.frame = self.view.frame;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

