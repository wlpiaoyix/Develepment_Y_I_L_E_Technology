//
//  PYCalendarDicEnums.swift
//  Calendar
//
//  Created by ydb on 15/4/23.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import Foundation
import UIKit

let PYLetCalenderWeekDays:Array<String> = ["Sun","Mon","Tues","Wed","Thur","Fir","Sat"]

class PYCalssCalenderStruct{
    var point:CGPoint
    var origin:CGPoint
    var size:CGSize
    
    init(){
        self.point = CGPointMake(0, 0)
        self.origin = CGPointMake(0, 0)
        self.size = CGSizeMake(0, 0)
    }
    init(point:CGPoint, origin:CGPoint, size:CGSize, key:String){
        self.point = point
        self.origin = origin
        self.size = size
    }

}



enum PYEnumCalendarDictionaryDrawKey:NSString{
    case WeekDay = "asdfas"
    case Day = "dea"
}