//
//  PYCalendarBaseView.swift
//  PYCalendar
//
//  Created by wlpiaoyi on 15/4/26.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class PYCalendarBaseView: UIView,PYCalendarBaseDrawDelegate {
    private var drawView = PYCalendarBaseDraw()
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
        frame.origin.y = 0
        frame.size.height *= 2;
        self.drawView.frame = frame
        self.clipsToBounds = true
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
    }
    func displayDate(){
        self.drawView.displayLayerDate()
    }
    func getDate()->NSDate{
        return self.drawView.getCurrentDate()
    }
    
    
    func touchUp(#structs:PYCalssCalenderStruct, touchPoint:CGPoint){
        println(NSString(format: "%d", structs.index))
    }
    
    func drawBefore(#boundsHeight:CGFloat){
        var frame = self.frame
        frame.size.height = boundsHeight
        self.frame = frame
    }
    
    private func initParam(){
        self.drawView.removeFromSuperview()
        self.addSubview(drawView)
        self.drawView.delegateDraw = self
//        self.drawView.drawOpteHandler = PYCaldrawOpteHandlerImpl
    }
}

