//
//  PYCalenderWeekDraw.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

public class PYCalenderWeekDraw: NSObject {
    public var weekWorkFont = UIFont.systemFontOfSize(12)
    public var weekWorkColor = UIColor.blackColor()
    public var weekendFont = UIFont.systemFontOfSize(12)
    public var weekendColor = UIColor.redColor()
    
    public func draw(#context:CGContextRef?, drawDic:NSDictionary, structDic:NSDictionary, boundSize:CGSize){
        var values = drawDic.objectForKey(PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue) as! NSArray;
        var index:Int = 0;
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
    public func setDraw(#drawDic:NSMutableDictionary, structDic:NSDictionary, itemSize:CGSize, offH:CGFloat){
        var index:Int = 0
        let endIndex:Int = PYLetCalenderWeekDays.count-1;
        var weekAttributes = NSMutableArray();
        var point = CGPointMake(0, offH);
        for weekDay in PYLetCalenderWeekDays {
            var color:UIColor?
            var font:UIFont?
            switch index {
            case 0,endIndex:
                color = weekendColor
                font = weekendFont
                break
            default:
                color = weekWorkColor
                font = weekWorkFont
                break
            }
            
            var key = self.classForCoder.getWeekKey(index: index) as String
            
            var structs:PYCalssCalenderStruct?
            PYCalSetStructs(index: index, 0, font!, color!, itemSize, point, &structs)
            
            point.x += structs!.size.width
            structDic.setValue(structs, forKey: key);
            
            weekAttributes.addObject(weekDay)
            index++
        }
        drawDic.setObject(weekAttributes, forKey: PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue)
    }
    public class func getWeekKey(#index:Int)->NSString{
        return NSString(format: "week%d", index);
    }
}
