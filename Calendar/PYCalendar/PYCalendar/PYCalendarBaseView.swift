//
//  PYCalendarBaseView.swift
//  PYCalendar
//
//  Created by wlpiaoyi on 15/4/26.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class PYCalendarBaseView: UIView,PYCalendarBaseDrawDelegate {
    private var flagTodayDate = false
    private var todateDate = Int(0)
    private var drawView = PYCalendarBaseDraw()
    var thumb:PYGraphicsThumb?
    var structs:PYCalssCalenderStruct?
    var flagDisplay = false
    
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
        var today = NSDate()
        self.flagTodayDate = (date.Year() == today.Year() && date.month() == today.month())
        self.todateDate = today.day()!
        self.drawView.setCurrentDate(date)
        self.structs = nil
        self.thumb?.executDisplay(self)
    }
    func displayDate(){
        self.drawView.displayLayerDate()
    }
    func getDate()->NSDate{
        return self.drawView.getCurrentDate()
    }
    
    
    func touchUp(#structs:PYCalssCalenderStruct?, touchPoint:CGPoint){
        println(NSString(format: "%d", structs!.index))
        if(self.thumb == nil){
            self.thumb = PYGraphicsThumb.newInstance(view: self.drawView, callback: { (context, userInfo) -> Void in
                
                var structs = (userInfo as! PYCalendarBaseView).structs
                if(structs != nil && structs?.isEnable == true && structs?.type == 1){
                    var rect = CGRectMake(0, 0, 0, 0)
                    rect.origin = structs!.mainbounds.origin
                    rect.size = structs!.mainbounds.size
                    PYCalGraphicsDraw.drawEllipse(context: context, rect: rect, strokeColor: UIColor.greenColor().CGColor, fillColor: nil, strokeWidth: 2)
                }
            })
        }
        self.structs = structs
        if(self.structs!.isEnable == true && self.structs!.type == 1){
            self.thumb?.executDisplay(self)
        }
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
        self.drawView.drawOpteHandler2 = PYCaldrawOpteHandlerImpl
        self.drawView.userInfo2 = self
    }
}
func PYCaldrawOpteHandlerImpl(context:CGContextRef?, structs:PYCalssCalenderStruct, userInfo:AnyObject?)->Void{
    var p = structs.mainbounds.origin;
    p.x += 1
    p.y += structs.mainbounds.size.height - 1
    var p2 = p
    p2.x += structs.mainbounds.size.width - 2
    PYCalGraphicsDraw.drawLine(context: context, startPoint: p, endPoint: p2, strokeColor: UIColor.yellowColor().CGColor, strokeWidth: 0.5, lengthPointer: nil, count: 0)
    var cbv = userInfo as! PYCalendarBaseView
    
    p = structs.valuebounds.origin
    p.x += structs.valuebounds.size.width/2 - 2
    p.y += structs.valuebounds.size.height + 5
    
    p2 = p
    p2.x += 2
    if(structs.index == cbv.structs?.index){
        cbv.structs = structs
        cbv.thumb?.executDisplay(cbv)
    }
    if( cbv.flagTodayDate == true && structs.isEnable == true && (structs.value as NSString).integerValue == cbv.todateDate){
        PYCalGraphicsDraw.drawLine(context: context, startPoint: p, endPoint: p2, strokeColor: UIColor.redColor().CGColor, strokeWidth: 4, lengthPointer: nil, count: 0)
    }
    
}

