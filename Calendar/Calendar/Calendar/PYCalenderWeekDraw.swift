//
//  PYCalenderWeekDraw.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

public class PYCalenderWeekDraw: NSObject {
    public var weekWorkFont = UIFont.systemFontOfSize(18)
    public var weekWorkColor = UIColor.blackColor()
    public var weekendFont = UIFont.systemFontOfSize(18)
    public var weekendColor = UIColor.redColor()
    
    public func draw(#context:CGContextRef?, drawDic:NSDictionary, structDic:NSDictionary, boundSize:CGSize){
        var attributes = drawDic.objectForKey(PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue) as! NSArray;
        var index:Int = 0;
        for attribute in attributes {
            var rect = CGRectMake(0, 0, boundSize.width, boundSize.height)
            var structs = structDic.valueForKey(self.classForCoder.getWeekKey(index: index) as String) as! PYCalssCalenderStruct
            rect.origin = structs.origin
            PYCalGraphicsDraw.drawText(context: context, attribute: attribute as! NSMutableAttributedString , rect: rect, y: boundSize.height, scaleFlag: false);
            index++
        }
    }
    public func setDraw(#drawDic:NSMutableDictionary, structDic:NSDictionary, itemSize:CGSize, offH:CGFloat){
        var index:Int = 0
        let endIndex:Int = PYLetCalenderWeekDays.count-1;
        var weekAttributes = NSMutableArray();
        for weekDay in PYLetCalenderWeekDays {
            var attribute:NSMutableAttributedString = NSMutableAttributedString(string:weekDay)
            var range = NSMakeRange(0, attribute.length);
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
            attribute.addAttribute(kCTForegroundColorAttributeName as String, value: color!, range: range)
            attribute.addAttribute(kCTFontAttributeName as String, value: font!, range: range)
            weekAttributes.addObject(attribute)
            index++
        }
        drawDic.setObject(weekAttributes, forKey: PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue)
        
        var point = CGPointMake(0, offH);
        for var i = 0; i < 7; i++ {
            
            var font:UIFont?
            switch i {
            case 0,endIndex:
                font = weekendFont
                break
            default:
                font = weekWorkFont
                break
            }
            var height:CGFloat = font!.getTextHeight();
            
            var sizeWeekend = PYCalUnit.getBoundSize(text: PYLetCalenderWeekDays[i], font: font!, size: CGSizeMake(999, height));
            
            var key = self.classForCoder.getWeekKey(index: i) as String
            var structs = PYCalssCalenderStruct(point: point, origin: CGPointMake(point.x + (itemSize.width - sizeWeekend.width)/2, point.y + (itemSize.height - sizeWeekend.height)/2), size: itemSize, key: key);
            point.x += structs.size.width
            structDic.setValue(structs, forKey: key);
        }
    }
    public class func getWeekKey(#index:Int)->NSString{
        return NSString(format: "week%d", index);
    }
}
