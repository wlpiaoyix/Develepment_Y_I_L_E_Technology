//
//  PYCalenderWeekDraw.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class PYCalenderWeekDraw: NSObject {
    var weekWorkFont = UIFont.systemFontOfSize(12)
    var weekWorkColor = UIColor.blackColor()
    var weekendFont = UIFont.systemFontOfSize(12)
    var weekendColor = UIColor.redColor()
    
    func draw(#context:CGContextRef?, drawDic:NSDictionary, structDic:NSDictionary, boundSize:CGSize, drawOpteHandler:PYCaldrawOpteHandler?, userInfo:AnyObject?){
        var values = drawDic.objectForKey(PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue) as! NSArray;
        var index:Int = 0;
        for value in values {
            var rect = CGRectMake(0, 0, boundSize.width, boundSize.height)
            var structs = structDic.valueForKey(self.classForCoder.getWeekKey(index: index) as String) as! PYCalssCalenderStruct
            var attribute:NSMutableAttributedString?
            var origin:CGPoint?
            PYCalCreateAttribute(structs, value as! String, &attribute, &origin)
            if(drawOpteHandler != nil){
                drawOpteHandler!(context!,structs,&attribute,&origin,userInfo)
            }
            rect.origin = origin!
            PYCalGraphicsDraw.drawText(context: context, attribute: attribute, rect: rect, y: boundSize.height, scaleFlag: false);
            index++
        }
    }
    func setDraw(#drawDic:NSMutableDictionary, structDic:NSDictionary, itemSize:CGSize, offH:CGFloat){
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
    class func getWeekKey(#index:Int)->NSString{
        return NSString(format: "week%d", index);
    }
}
