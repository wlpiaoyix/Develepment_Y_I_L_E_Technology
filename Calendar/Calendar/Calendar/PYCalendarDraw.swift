//
//  PYCalendarView.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

protocol PYCalendarDrawDelegate : class {
    func touchUp(#structs:PYCalssCalenderStruct, point:CGPoint)
    func drawBefore(#height:CGFloat);
}

class PYCalendarDraw: UIView {
    
    var drawOpteHandler:PYCaldrawOpteHandler?
    var userInfo:AnyObject?
    
    var heightHead:CGFloat = 30
    var heightCell:CGFloat = 30
    var flagAutoHeight = true
    
    weak var delegateDraw:PYCalendarDrawDelegate?
    
    private var structDic = NSMutableDictionary()
    private var drawDic = NSMutableDictionary()
    private var currentDate = NSDate();
    
    private var flagTouchMoved = false;
    
    private var weekDraw = PYCalenderWeekDraw()
    private var dayDraw = PYCalenderDayDraw()
    
    private var thumb:PYGraphicsThumb?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initParam()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initParam()
    }
    
    func getCurrentDate()->NSDate{
        return self.currentDate
    }
    func setCurrentDate(date:NSDate){
        currentDate = date;
        drawDic.removeAllObjects()
        structDic.removeAllObjects()
    }
    func displayLayerDate(){
        self.thumb!.executDisplay(nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clearColor()
    
    }
    
    private func startDraw(#context:CGContextRef?){
        self.dayDraw.currentDate = self.currentDate;
        if(flagAutoHeight == true){
            var firstWeekDay = self.currentDate.firstWeekDayInMonth()
            var numDays = self.currentDate.numDaysInMounth()
            numDays += firstWeekDay
            var maxRow = 0;
            if(numDays % PYLetCalenderWeekDays.count > 0){
                numDays -= numDays % PYLetCalenderWeekDays.count;
                ++maxRow;
            }
            maxRow += numDays / PYLetCalenderWeekDays.count
            self.heightCell = (self.frame.size.height / 2 - self.heightHead) / CGFloat(maxRow)
        }
        
        var hOff:CGFloat = 0;
        var size = CGSizeMake(self.frame.size.width/CGFloat(PYLetCalenderWeekDays.count), self.heightHead)
        self.weekDraw.setDraw(drawDic: self.drawDic, structDic: self.structDic, itemSize:size, offH:hOff)
        hOff += size.height
        size.height = self.heightCell
        
        var height:CGFloat?
        self.dayDraw.setDraw(drawDic: self.drawDic, structDic: self.structDic, itemSize: size, offH: hOff, poinerHieght: &height)
        
        if(self.delegateDraw != nil){
            self.delegateDraw!.drawBefore(height: height!)
        }
        self.dayDraw.userInfo = self.userInfo
        self.weekDraw.userInfo = self.userInfo
        self.dayDraw.drawOpteHandler = self.drawOpteHandler
        self.weekDraw.drawOpteHandler = self.drawOpteHandler
        
        var values = drawDic.objectForKey(PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue) as! NSArray
        self.weekDraw.draw(context: context, values:values, structDic: self.structDic, boundSize: self.bounds.size)
        values = drawDic.objectForKey(PYEnumCalendarDictionaryDrawKey.Day.rawValue) as! NSArray
        self.dayDraw.draw(context: context, values:values, structDic: self.structDic, boundSize: self.bounds.size)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event);
        var point = PYCalendarDraw.getTouchPoint(touches)
        flagTouchMoved = false
        
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event);
        var point = PYCalendarDraw.getTouchPoint(touches)
        flagTouchMoved = true;
        
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event);
        var point = PYCalendarDraw.getTouchPoint(touches)
        if(flagTouchMoved == false){
            var structs:PYCalssCalenderStruct?
            var key:NSString?
            self.checkStructDic(point: point, pointerStruct: &structs, pointerKey: &key)
            if(key != nil && self.delegateDraw != nil){
                self.delegateDraw!.touchUp(structs:structs!, point: point)
            }
        }
    }
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event);
        
    }
    
    private func initParam(){
        self.setCurrentDate(NSDate());
        self.thumb = PYGraphicsThumb.newInstance(view: self, callback: { (contextRef, userInfo) -> Void in
            PYCalGraphicsDraw.drawText(context: contextRef, attribute: NSMutableAttributedString(string: ""), rect: self.bounds, y: self.bounds.size.height, scaleFlag: true)
            self.startDraw(context: contextRef)
        })
        
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 1;
        self.layer.shadowPath = nil;
        self.layer.shadowColor = UIColor.whiteColor().CGColor
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.clipsToBounds = false;
    }
    
    
    private func checkStructDic(#point:CGPoint,pointerStruct:UnsafeMutablePointer<PYCalssCalenderStruct?>,pointerKey:UnsafeMutablePointer<NSString?>){
        if (pointerKey == nil || pointerStruct == nil){
            return
        }
        var allKeys = self.structDic.allKeys
        for key in allKeys{
            var target = self.structDic.objectForKey(key) as? PYCalssCalenderStruct
            if(target!.point.x < point.x && target!.point.y < point.y && target!.point.x + target!.size.width > point.x && target!.point.y + target!.size.height > point.y ){
                pointerStruct.memory = target
                pointerKey.memory = key as? NSString
                return
            }
        }
        return
    }
    private class func getTouchPoint(touches: Set<NSObject>!)->CGPoint{
        var touch = touches.first as? UITouch
        var point = CGPointMake(-1, -1)
        if(touch != nil){
            point = touch!.locationInView(touch!.view)
        }
        return point
    }
}

//func PYCaldrawOpteHandlerImpl(context:CGContextRef?, structs:PYCalssCalenderStruct, pointerAttribute:UnsafeMutablePointer<NSMutableAttributedString?>, pointerOrigin:UnsafeMutablePointer<CGPoint?>, userInfo:AnyObject?){
//    
//}
