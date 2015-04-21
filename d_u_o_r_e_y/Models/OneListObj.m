//
//  OneListObj.m
//  Duorey
//
//  Created by lixu on 14/11/19.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "OneListObj.h"

@implementation OneListObj

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"music.sid":@"sid",
             @"music.":@"name",
             @"music.":@"url",
             @"music.":@"meid",
             @"music.":@"eid",
             @"music.":@"source_type",
             @"music.":@"style",
             @"music.":@"time_length",
             @"music.":@"album",
             @"music.":@"ico_big",
             @"music.":@"ico_small",
             @"music.":@"ico_nomal",
             @"music.":@"pub_year",
             @"music.":@"singer",
             @"music.":@"music_lang",
             @"music.":@"creater",
             @"ower":@"ower"
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

@end
