//
//  ViewController.swift
//  PYCalendar
//
//  Created by wlpiaoyi on 15/4/26.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var dateView = PYCalendarBaseView()
    var buttonPre = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
    var buttonNext = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(buttonPre)
        self.view.addSubview(buttonNext)
        self.view.addSubview(dateView)
        self.dateView.setDate(date: NSDate())
        self.buttonPre.addTarget(self, action: "onclickPre", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonNext.addTarget(self, action: "onclickNext", forControlEvents: UIControlEvents.TouchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func onclickPre(){
        self.dateView.offsetMonth(-1)
        self.dateView.displayDate()
    }
    func onclickNext(){
        self.dateView.offsetMonth(1)
        self.dateView.displayDate()
    }
    override func viewDidLayoutSubviews() {
        var r = CGRectMake(10, 20, 60, 30)
        self.buttonPre.frame = r
        r.origin.x += r.size.width + 10
        self.buttonNext.frame = r
        
        r.origin.y += r.size.height + 10
        r.origin.x = 10
        r.size.width = self.view.frame.size.width - r.origin.x * 2
        r.size.height = self.view.frame.size.height - r.origin.y - 10
        self.dateView.frame = r
        
        self.dateView.displayDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

