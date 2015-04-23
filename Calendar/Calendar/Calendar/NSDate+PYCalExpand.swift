//
//  NSDate+PYCalExpand.swift
//  Calendar
//
//  Created by ydb on 15/4/22.
//  Copyright (c) 2015年 wlpiaoyi. All rights reserved.
//

import Foundation

extension NSDate {
    
    func month()->Int?{
        var gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        var components = gregorian?.components(NSCalendarUnit.MonthCalendarUnit, fromDate: self)
        return components?.month
    }
    
    func offsetMonth(numMonths:Int)->NSDate?{
        var gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        gregorian?.firstWeekday = 1
        var offsetComponents = NSDateComponents()
        offsetComponents.month = numMonths
        var date = gregorian?.dateByAddingComponents(offsetComponents, toDate: self, options: NSCalendarOptions.allZeros)
        return date
    }
    
    func offsetYear(numYears:Int)->NSDate?{
        var gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        gregorian?.firstWeekday = 1
        var offsetComponents = NSDateComponents()
        offsetComponents.year = numYears
        var date = gregorian?.dateByAddingComponents(offsetComponents, toDate: self, options: NSCalendarOptions.allZeros)
        return date
    }
    
    
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
    
    func firstWeekDayInMonth()->Int{
        var gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        gregorian?.firstWeekday = 1;
        var comps = gregorian!.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: self)
        comps.day = 1;
        var newDate = gregorian!.dateFromComponents(comps)
        var result = gregorian!.ordinalityOfUnit(NSCalendarUnit.WeekdayCalendarUnit, inUnit: NSCalendarUnit.WeekCalendarUnit, forDate: newDate!)
        return result-1
    }
}
