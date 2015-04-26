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
        self.drawView.drawOpteHandler = PYCaldrawOpteHandlerImpl
    }
}
func PYCaldrawOpteHandlerImpl(structs:PYCalssCalenderStruct, pointerAttribute:UnsafeMutablePointer<NSMutableAttributedString?>, pointerOrigin:UnsafeMutablePointer<CGPoint?>){
//    if(structs.type == 0){
//        var startPoint = CGPointMake(structs.point.x+5, structs.point.y + structs.size.height)
//        var endPoint = CGPointMake(structs.point.x-5 + structs.size.width, structs.point.y + structs.size.height)
//        startPoint.y = 600 - startPoint.y
//        endPoint.y = 600 - endPoint.y
//        var lengths = [CGFloat(4),CGFloat(2)]
//        
//        PYCalGraphicsDraw.drawLine(context: context, startPoint: startPoint, endPoint: endPoint, strokeColor: UIColor.grayColor().CGColor, strokeWidth: 0.3, lengthPointer: lengths, count: 2)
//    }
}
