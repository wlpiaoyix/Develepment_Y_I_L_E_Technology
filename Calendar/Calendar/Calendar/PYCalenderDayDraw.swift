//
//  PYCalenderDayDraw.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

public class PYCalenderDayDraw: NSObject {
    public var dayWorkFont = UIFont.systemFontOfSize(18)
    public var dayWorkColor = UIColor.blackColor()
    public var dayendFont = UIFont.systemFontOfSize(18)
    public var dayendColor = UIColor.redColor()
    public var currentDate:NSDate?
    
    
    public func draw(#context:CGContextRef?, drawDic:NSDictionary, structDic:NSDictionary, boundSize:CGSize){
        var values = drawDic.objectForKey(PYEnumCalendarDictionaryDrawKey.Day.rawValue) as! NSArray;
        var index:Int = 1;
        for value in values {
            var rect = CGRectMake(0, 0, boundSize.width, boundSize.height)
            var structs = structDic.valueForKey(self.classForCoder.getWeekKey(index: index) as String) as! PYCalssCalenderStruct
            var attribute:NSMutableAttributedString?
            var origin:CGPoint?
            PYCalCreateStructs(structs, value as! String, &attribute, &origin)
            rect.origin = origin!
            PYCalGraphicsDraw.drawText(context: context, attribute: attribute, rect: rect, y: boundSize.height, scaleFlag: false);
            index++
        }
    }
    public func setDraw(#drawDic:NSMutableDictionary, structDic:NSDictionary, itemSize:CGSize, offH:CGFloat, poinerHieght:UnsafeMutablePointer<CGFloat?>?){
        if(self.currentDate == nil){
            return
        }
        var index = self.currentDate!.firstWeekDayInMonth()
        var numDay = self.currentDate!.numDaysInMounth()
        var point = CGPointMake(0, offH)
        
        var day = 1;
        let count:Int = PYLetCalenderWeekDays.count;
        var dayAttributes = NSMutableArray();
        for var i = 0; i < 31 / count + 2; i++ {
            var flagBreak = false
            for var j = index; j < count; j++ {
                var color:UIColor?
                var font:UIFont?
                switch j {
                case 0,count-1:
                    color = dayendColor
                    font = dayendFont
                    break
                default:
                    color = dayWorkColor
                    font = dayWorkFont
                    break
                }
                
                point.x = CGFloat(j) * itemSize.width
                
                var key = self.classForCoder.getWeekKey(index: day) as String
                var structs:PYCalssCalenderStruct?
                PYCalSetStructs(index: day, 1, font!, color!, itemSize, point, &structs)
                structDic.setValue(structs!, forKey: key);
                
                dayAttributes.addObject(NSString(format: "%d", day))
                ++day
                if(day > numDay){
                    flagBreak = true
                    break
                }
            }
            if(flagBreak == true){
                poinerHieght?.memory = point.y + itemSize.height
                break
            }
            index = 0
            point.y += itemSize.height
            
            drawDic.setObject(dayAttributes, forKey: PYEnumCalendarDictionaryDrawKey.Day.rawValue)
        }
    }
    public class func getWeekKey(#index:Int)->NSString{
        return NSString(format: "day%d", index);
    }
}

