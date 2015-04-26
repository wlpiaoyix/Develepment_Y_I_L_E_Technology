//
//  PYCalenderWeekDraw.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import UIKit

class PYCalenderWeekDraw: NSObject {
    var drawOpteHandler:PYCaldrawOpteHandler?
    var userInfo:AnyObject?
    
    var weekWorkFont = UIFont.systemFontOfSize(12)
    var weekWorkColor = UIColor.blackColor()
    var weekendFont = UIFont.systemFontOfSize(12)
    var weekendColor = UIColor.redColor()
    
    func startDraw(#context:CGContextRef?, structDic:NSDictionary, boundSize:CGSize){
        var index:Int = 0;
        var structsArray = structDic.objectForKey(PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue) as! NSArray
        for _struct_ in structsArray {
            var structs = _struct_ as! PYCalssCalenderStruct
            if(drawOpteHandler != nil){
                drawOpteHandler!(context, structs, self.userInfo)
            }
            var attribute:NSMutableAttributedString?
            PYCalCreateAttribute(structs,  &attribute)
            var rect = CGRectMake(structs.valuebounds.origin.x, structs.valuebounds.origin.y, boundSize.width, boundSize.height)
            PYCalGraphicsDraw.drawText(context: context, attribute: attribute, rect: rect, y: boundSize.height, scaleFlag: false);
            index++
        }
    }
    func setDraw(#structDic:NSMutableDictionary, itemSize:CGSize, offH:CGFloat){
        var index:Int = 0
        let endIndex:Int = PYLetCalenderWeekDays.count-1;
        var strtucts = NSMutableArray();
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
            var mainbounds = CGRectMake(point.x, point.y, itemSize.width, itemSize.height)
            PYCalSetStructs(index: index, 0, font!, color!, mainbounds, weekDay, &structs)
            
            point.x += structs!.mainbounds.size.width
            strtucts.addObject(structs!);
            index++
        }
        structDic.setObject(strtucts, forKey: PYEnumCalendarDictionaryDrawKey.WeekDay.rawValue)
    }
    class func getWeekKey(#index:Int)->NSString{
        return NSString(format: "week%d", index);
    }
}
