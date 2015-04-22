//
//  PYCalendarView.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

let PYCalendarDicKeyYearAttribute = "asdsdeegh"


public class PYCalendarView: UIView {
    public var yearFont = UIFont.boldSystemFontOfSize(24);
    public var yearColor = UIColor.redColor();
    
    private var drawDic = NSMutableDictionary();
    private var currentDate = NSDate();
    private var scaleFlag = false;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initParam()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initParam()
    }
    
    
    public func setCurrentDate(date:NSDate){
        currentDate = date;
        drawDic.removeAllObjects()
        self.setDrawYear(date: currentDate);
    }
    
    
    override public func drawRect(rect: CGRect) {
        self.startDraw(context: nil)
    }
    private func startDraw(#context:CGContextRef?){
        if(self.scaleFlag == false){
            
            PYCalGraphicsDraw.drawText(context: context, attribute: NSMutableAttributedString(string: ""), rect: self.bounds, y: self.bounds.size.height, scaleFlag: true)
            self.scaleFlag = true;
        }
        self.drawYear(context: nil, point: CGPointMake(10, 10));
    }
    
    private func initParam(){
        self.setCurrentDate(NSDate());
    }
    
    private func drawYear(#context:CGContextRef?, point:CGPoint){
        var attribute = drawDic.objectForKey(PYCalendarDicKeyYearAttribute) as? NSMutableAttributedString;
        if(attribute != nil){
            var rect = self.frame
            rect.origin = point
            PYCalGraphicsDraw.drawText(context: context, attribute: attribute, rect: rect, y: self.bounds.size.height, scaleFlag: false);
        }
    }
    private func setDrawYear(#date:NSDate){
        var text = currentDate.dateFormate("YYYY-MM-dd");
        var range = NSMakeRange(0, text.length)
        var attribute:NSMutableAttributedString = NSMutableAttributedString(string:text as String)
        attribute.addAttribute(kCTForegroundColorAttributeName as String, value: yearColor, range: range)
        attribute.addAttribute(kCTFontAttributeName as String, value: yearFont, range: range)
        drawDic.setObject(attribute, forKey: PYCalendarDicKeyYearAttribute)
    }


}
