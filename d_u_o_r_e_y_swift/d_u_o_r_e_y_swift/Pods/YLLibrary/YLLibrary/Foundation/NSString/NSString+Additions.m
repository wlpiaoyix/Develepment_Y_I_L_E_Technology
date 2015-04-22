//
//  NSString+Additions.m
//  PhonTunes
//
//  Created by xdy on 14-2-18.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isEmpty {
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self stringByTrimmingCharactersInSet:charSet];
    return [trimmed isEqualToString:@""];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)firstCharacterUppercase {
	CFStringRef cfStringRef = (__bridge CFStringRef)[self trim];
	CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, cfStringRef);
    CFStringTransform(string, NULL, kCFStringTransformToLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripCombiningMarks, NO);

    NSString *first = [[(__bridge NSString *)string substringToIndex:1] uppercaseString];

    CFRelease(string);

	return first;
}

- (NSString *)firstCharacterLowercase {
    CFStringRef cfStringRef = (__bridge CFStringRef)[self trim];
	CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, cfStringRef);
    CFStringTransform(string, NULL, kCFStringTransformToLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripCombiningMarks, NO);

    NSString *first = [[(__bridge NSString *)string substringToIndex:1] lowercaseString];

    CFRelease(string);
    
	return first;
}

- (long)videoDuration {
    NSString *timeString = [self videoDurationString];
    NSArray *times = [timeString componentsSeparatedByString:@":"];
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    
    NSUInteger count = [times count];
    if (count == 3) {
        hours = [times[0] intValue];
        minutes = [times[1] intValue];
        seconds = [times[2] intValue];
    } else if (count == 2) {
        minutes = [times[0] intValue];
        seconds = [times[1] intValue];
    } else {
        seconds = [times[0] intValue];
    }
    
    return hours * 3600 + minutes * 60 + seconds;
}

+ (long)videoDurationFromNSString:(NSString *)dstr {
    NSArray *times = [dstr componentsSeparatedByString:@":"];
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    
    NSUInteger count = [times count];
    if (count == 3) {
        hours = [times[0] intValue];
        minutes = [times[1] intValue];
        seconds = [times[2] intValue];
    } else if (count == 2) {
        minutes = [times[0] intValue];
        seconds = [times[1] intValue];
    } else {
        seconds = [times[0] intValue];
    }
    
    return hours * 3600 + minutes * 60 + seconds;
}

- (NSString *)videoDurationString {
    NSString *timeString = [[[self trim] stringByReplacingOccurrencesOfString:@"PT" withString:@""] uppercaseString];
    timeString = [timeString stringByReplacingOccurrencesOfString:@"H" withString:@":"];
    timeString = [timeString stringByReplacingOccurrencesOfString:@"M" withString:@":"];
    timeString = [timeString stringByReplacingOccurrencesOfString:@"S" withString:@""];
    
    NSArray *times = [timeString componentsSeparatedByString:@":"];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[times count]];
    for (NSString *str in times) {
        [results addObject:[NSString stringWithFormat:@"%02d",[str intValue]]];
    }
    return [results componentsJoinedByString:@":"];
}

@end
