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
        if(frame.size.width != self.drawView.frame.size.width){
            frame.origin.y = 0
            frame.size.height *= 2;
            self.drawView.frame = frame
            self.clipsToBounds = true
        }
    }
    func offsetMonth(month:Int){
        var date = self.drawView.getCurrentDate().offsetMonth(month)
        self.setDate(date: date!)
    }
    func offsetYear(year:Int){
        var date = self.drawView.getCurrentDate().offsetYear(year)
        self.setDate(date: date!)
    }
    func setDate(#date:NSDate){
        self.drawView.setCurrentDate(date)
        self.drawView.displayLayerDate()
    }
    func getDate()->NSDate{
        return self.drawView.getCurrentDate()
    }
    
    
    func touchUp(#structs:PYCalssCalenderStruct, point:CGPoint){
        println(NSString(format: "%d", structs.index))
    }
    
    func drawBefore(#height:CGFloat){
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
    }
    
    private func initParam(){
        self.drawView.removeFromSuperview()
        self.addSubview(drawView)
        self.drawView.delegateDraw = self
    }
    
}
