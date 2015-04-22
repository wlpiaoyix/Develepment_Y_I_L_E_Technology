
#import <Foundation/Foundation.h>

@interface NSDate (TimeAgo)

/**
 *  返回以{value}{unit-abbreviation}为格式的字符串
 *
 *  @return 时间字符串
 */
- (NSString *)timeAgoSimple;

/**
 *  返回类似1d, 1h, 1m的字符串
 *
 *  @return 字符串
 */
- (NSString *)timeAgo;


- (NSString *)timeAgoWithLimit:(NSTimeInterval)limit;
- (NSString *)timeAgoWithLimit:(NSTimeInterval)limit dateFormat:(NSDateFormatterStyle)dFormatter andTimeFormat:(NSDateFormatterStyle)tFormatter;

- (NSString *)timeAgoWithLimit:(NSTimeInterval)limit dateFormatter:(NSDateFormatter *)formatter;

/**
 *  返回以{value} {unit} ago和yesterday / last month格式的字符串
 */
- (NSString *)dateTimeAgo;

/**
 *  this method gives when possible the date compared to the current calendar date: "this morning"/"yesterday"/"last week"/..
 *  when more precision is needed (= less than 6 hours ago) it returns the same output as dateTimeAgo
 *
 *
 *  @return 字符串
 */
//
//
- (NSString *)dateTimeUntilNow;

@end

