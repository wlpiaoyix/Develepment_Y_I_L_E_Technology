//
//  PYCalendarDicEnums.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import Foundation
import UIKit

let PYLetCalenderWeekDays:Array<String> = ["Sun","Mon","Tue","Wed","Thur","Fir","Sat"]
typealias PYCaldrawOpteHandler = (PYCalssCalenderStruct,UnsafeMutablePointer<NSMutableAttributedString?>,UnsafeMutablePointer<CGPoint?>)->Void
class PYCalssCalenderStruct{
    var point:CGPoint
    var style:NSDictionary
    var size:CGSize
    var index:Int
    var type:Int
    
    init(){
        self.point = CGPointMake(0, 0)
        self.style = NSDictionary()
        self.size = CGSizeMake(0, 0)
        self.index = 0
        self.type = 0
    }
    init(point:CGPoint, style:NSDictionary, size:CGSize, index:Int, type:Int){
        self.point = point
        self.style = style
        self.size = size
        self.index = index
        self.type = type
    }

}



enum PYEnumCalendarDictionaryDrawKey:NSString{
    case WeekDay = "a"
    case Day = "b"
    case StyleValueFont = "c"
    case StyleValueColor = "d"
}


func PYCalSetStructs(#index:Int, type:Int, font:UIFont, color:UIColor, itemSize:CGSize, point:CGPoint, pointerStruct:UnsafeMutablePointer<PYCalssCalenderStruct?>){
    
    var style = [
        PYEnumCalendarDictionaryDrawKey.StyleValueFont.rawValue:font,
        PYEnumCalendarDictionaryDrawKey.StyleValueColor.rawValue:color
    ]
    var structs = PYCalssCalenderStruct(point: point, style: style, size: itemSize, index: index, type:type)
    pointerStruct.memory = structs
}

func PYCalCreateAttribute(structs:PYCalssCalenderStruct, value:String, pointerAttribute:UnsafeMutablePointer<NSMutableAttributedString?>, pointerOrigin:UnsafeMutablePointer<CGPoint?>){
    
    var font = structs.style.objectForKey(PYEnumCalendarDictionaryDrawKey.StyleValueFont.rawValue) as? UIFont
    var color = structs.style.objectForKey(PYEnumCalendarDictionaryDrawKey.StyleValueColor.rawValue) as? UIColor
    
    var itemSize = structs.size
    var attribute:NSMutableAttributedString = NSMutableAttributedString(string:value)
    var range = NSMakeRange(0, attribute.length);
    attribute.addAttribute(kCTForegroundColorAttributeName as String, value: color!, range: range)
    attribute.addAttribute(kCTFontAttributeName as String, value: font!, range: range)
    
    
    var sizeDay = PYCalUnit.getBoundSize(text: attribute.string, font: font!, size: CGSizeMake(999, font!.getTextHeight()))
    var origin = CGPointMake(structs.point.x + (itemSize.width - sizeDay.width)/2, structs.point.y + (itemSize.height - sizeDay.height)/2)
    
    pointerAttribute.memory = attribute
    pointerOrigin.memory = origin
}