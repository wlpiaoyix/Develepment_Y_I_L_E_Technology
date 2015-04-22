//
//  NSDate+PYCalExpand.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import Foundation

extension NSDate {
    
    func dateFormate(formatePattern:NSString?)->NSString{
        var dft = NSDateFormatter();
        var dateFormat = ((formatePattern == nil || formatePattern!.length == 0) ? "yyyy-MM-dd HH:mm:ss" : formatePattern) as! String
        dft.dateFormat = dateFormat
        var result = dft.stringFromDate(self)
        return result
    }
    
    
    func numDaysInMounth()->Int{
        var cal = NSCalendar.currentCalendar()
        var rng = cal.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.MonthCalendarUnit, forDate: self)
        var numberOfDaysInMonth = rng.length
        return numberOfDaysInMonth
    }
}
