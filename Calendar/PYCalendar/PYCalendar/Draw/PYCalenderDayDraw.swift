//
//  PYCalenderDayDraw.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class PYCalenderDayDraw: NSObject {
    var drawOpteHandler:PYCaldrawOpteHandler?
    var userInfo:AnyObject?
    
    var dayWorkFont = UIFont.systemFontOfSize(18)
    var dayWorkColor = UIColor.blackColor()
    var dayWorkFontDis = UIFont.systemFontOfSize(18)
    var dayWorkColorDis = UIColor.grayColor()
    var dayendFont = UIFont.systemFontOfSize(18)
    var dayendColor = UIColor.redColor()
    var currentDate:NSDate?
    
    func startDraw(#context:CGContextRef?,structDic:NSDictionary, boundSize:CGSize){
        var index:Int = 1;
        var structsArray = structDic.objectForKey(PYEnumCalendarDictionaryDrawKey.Day.rawValue) as! NSArray
        for _struct_ in structsArray {
            var structs = _struct_ as! PYCalssCalenderStruct
            var attribute:NSMutableAttributedString?
            if(drawOpteHandler != nil){
                drawOpteHandler!(context, structs, self.userInfo)
            }
            var rect = CGRectMake(structs.valuebounds.origin.x, structs.valuebounds.origin.y, boundSize.width, boundSize.height)
            PYCalCreateAttribute(structs,  &attribute)
            PYCalGraphicsDraw.drawText(context: context, attribute: attribute, rect: rect, y: boundSize.height, scaleFlag: false);
            index++
        }
    }
    func setDraw(#structDic:NSMutableDictionary, itemSize:CGSize, offH:CGFloat, poinerHieght:UnsafeMutablePointer<CGFloat?>?){
        if(self.currentDate == nil){
            return
        }
        var firstDay = self.currentDate!.firstWeekDayInMonth()
        var numDay = self.currentDate!.numDaysInMounth()
        var index = firstDay
        var point = CGPointMake(0, offH)
        
        var day = 1;
        let count:Int = PYLetCalenderWeekDays.count;
        var structArray = NSMutableArray()
        var boolIfStart = false;
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
                
                var value = NSString(format: "%d", day)
                var mainbounds = CGRectMake(0, 0, 0, 0)
                mainbounds.origin = point
                mainbounds.size = itemSize
                var structs:PYCalssCalenderStruct?
                PYCalSetStructs(index: day + firstDay, 1, font!, color!, mainbounds, value as String, &structs)
                structArray.addObject(structs!);
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
        }
        
        index = count - (numDay + firstDay) % count
        for var k = index; k > 0; k-- {
            point.x += itemSize.width
            var value = NSString(format: "%d", index - k + 1)
            var mainbounds = CGRectMake(0, 0, 0, 0)
            mainbounds.origin = point
            mainbounds.size = itemSize
            var structs:PYCalssCalenderStruct?
            PYCalSetStructs(index: numDay + firstDay + index - k + 1 , 1, dayWorkFontDis, dayWorkColorDis, mainbounds, value as String, &structs)
            structs!.isEnable = false;
            structArray.addObject(structs!);
        }
        
        index = self.currentDate!.offsetMonth(-1)!.numDaysInMounth() - firstDay
        point = CGPointMake(0, offH)
        for var l = 1; l <= firstDay; l++ {
            var value = NSString(format: "%d", l + index - 1)
            var mainbounds = CGRectMake(0, 0, 0, 0)
            mainbounds.origin = point
            mainbounds.size = itemSize
            var structs:PYCalssCalenderStruct?
            PYCalSetStructs(index: l, 1, dayWorkFontDis, dayWorkColorDis, mainbounds, value as String, &structs)
            structs!.isEnable = false;
            structArray.addObject(structs!);
            point.x += itemSize.width
        }
        
        structDic.setObject(structArray, forKey: PYEnumCalendarDictionaryDrawKey.Day.rawValue)
    }
    class func getWeekKey(#index:Int)->NSString{
        return NSString(format: "day%d", index);
    }
}

