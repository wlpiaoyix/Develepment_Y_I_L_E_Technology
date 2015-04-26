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
typealias PYCaldrawOpteHandler = (PYCalssCalenderStruct,AnyObject?)->Void

class PYCalssCalenderStruct{
    var mainbounds:CGRect
    var valuebounds:CGRect
    var style:NSDictionary
    var value:String
    var index:Int
    var type:Int
    
    init(){
        self.mainbounds = CGRectMake(0, 0, 0, 0)
        self.valuebounds = CGRectMake(0, 0, 0, 0)
        self.value = ""
        self.style = NSDictionary()
        self.index = 0
        self.type = 0
    }
    init(mainbounds:CGRect, valuebounds:CGRect, value:String, style:NSDictionary, index:Int, type:Int){
        self.mainbounds = mainbounds
        self.valuebounds = valuebounds
        self.value = value
        self.style = style
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


func PYCalSetStructs(#index:Int, type:Int, font:UIFont, color:UIColor, mainbounds:CGRect, value:String, pointerStruct:UnsafeMutablePointer<PYCalssCalenderStruct?>){
    
    var style = [
        PYEnumCalendarDictionaryDrawKey.StyleValueFont.rawValue:font,
        PYEnumCalendarDictionaryDrawKey.StyleValueColor.rawValue:color
    ]
    var valuebounds = CGRectMake(0, 0, 0, 0)
    valuebounds.size.height = font.getTextHeight()
    valuebounds.size.width = 9999
    valuebounds.size = PYCalUnit.getBoundSize(text: value, font: font, size: valuebounds.size)
    valuebounds.origin.x = (mainbounds.size.width - valuebounds.size.width)/2 + mainbounds.origin.x
    valuebounds.origin.y = (mainbounds.size.height - valuebounds.size.height)/2 + mainbounds.origin.y
    var structs = PYCalssCalenderStruct(mainbounds: mainbounds, valuebounds: valuebounds, value: value, style: style, index: index, type: type)
    pointerStruct.memory = structs
}

func PYCalCreateAttribute(structs:PYCalssCalenderStruct,pointerAttribute:UnsafeMutablePointer<NSMutableAttributedString?>){
    
    var font = structs.style.objectForKey(PYEnumCalendarDictionaryDrawKey.StyleValueFont.rawValue) as? UIFont
    var color = structs.style.objectForKey(PYEnumCalendarDictionaryDrawKey.StyleValueColor.rawValue) as? UIColor
    var attribute:NSMutableAttributedString = NSMutableAttributedString(string:structs.value)
    var range = NSMakeRange(0, attribute.length);
    attribute.addAttribute(kCTForegroundColorAttributeName as String, value: color!, range: range)
    attribute.addAttribute(kCTFontAttributeName as String, value: font!, range: range)
    
    pointerAttribute.memory = attribute
}