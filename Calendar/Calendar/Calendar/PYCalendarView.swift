//
//  PYCalendarView.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class PYCalendarView: UIView,PYCalendarDrawDelegate {
    private var drawView = PYCalendarDraw()
    private var flagDisplay = false
    
    var button = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initParam()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initParam()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.bounds
        frame.origin.y = 60
        self.drawView.frame = frame
        self.backgroundColor = UIColor(red: 0.8, green: 0.9, blue: 0.9, alpha: 0.6)
        self.clipsToBounds = true
    }
    
    func touchUp(#key:NSString, point:CGPoint){
        println(key)
    }
    func drawEnd(#height:CGFloat){
        var frame = self.frame
        frame.size.height = height+60
        self.frame = frame
    }
    func onclick(){
        var month = self.drawView.getCurrentDate().month()
        var date = self.drawView.getCurrentDate().offsetMonth(1)
        self.drawView.setCurrentDate(date!)
        
        self.drawView.displayLayerDate()
    }
    
    private func initParam(){
        self.drawView.removeFromSuperview()
        self.addSubview(drawView)
        self.drawView.delegateDraw = self
        
        self.button.addTarget(self, action: "onclick", forControlEvents: UIControlEvents.TouchUpInside)
        self.button.frame = CGRectMake(0, 0, 80, 40)
        self.addSubview(self.button)
    }
    
}
