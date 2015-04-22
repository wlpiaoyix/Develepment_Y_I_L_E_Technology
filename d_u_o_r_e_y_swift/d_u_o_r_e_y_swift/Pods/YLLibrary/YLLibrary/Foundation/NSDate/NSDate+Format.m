//
//  NSDate+Format.m
//  Demo
//
//  Created by xdy on 13-12-12.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

- (NSString *)descriptionWithYYYYMMDD{
    NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [dataformatter setDateFormat:@"YYYY/MM/dd"];
    [dataformatter setCalendar:calendar];
    return [dataformatter stringFromDate:self];
}
@end
