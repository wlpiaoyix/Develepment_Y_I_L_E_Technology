//
//  ViewController.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var view01: PYCalendarView!
    var test:TestView! = TestView();
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillLayoutSubviews() {
        self.test.frame = self.view.frame;
    }
    @IBAction func onclick1(sender: AnyObject) {
        view01.offsetMonth(-1)
    }
    @IBAction func onclick2(sender: AnyObject) {
        view01.offsetMonth(1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

