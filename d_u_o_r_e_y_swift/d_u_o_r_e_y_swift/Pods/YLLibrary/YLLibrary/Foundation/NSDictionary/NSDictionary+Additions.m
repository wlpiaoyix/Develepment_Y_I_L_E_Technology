//
//  NSDictionary+Additions.m
//  Duorey
//
//  Created by yong on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

- (NSDictionary *)nestedDictionaryByReplacingNullsWithNil:(NSDictionary*)sourceDictionary {
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:sourceDictionary];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    [sourceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        object = [sourceDictionary objectForKey:key];
        if([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *innerDict = object;
            [replaced setObject:[self nestedDictionaryByReplacingNullsWithNil:innerDict] forKey:key];
            
        } else if([object isKindOfClass:[NSArray class]]){
            NSMutableArray *nullFreeRecords = [NSMutableArray array];
            for (id record in object) {
                if([record isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *nullFreeRecord = [self nestedDictionaryByReplacingNullsWithNil:record];
                    [nullFreeRecords addObject:nullFreeRecord];
                }
            }
            [replaced setObject:nullFreeRecords forKey:key];
        } else {
            if(object == nul) {
                [replaced setObject:blank forKey:key];
            }
        }
    }];
    
    return [NSDictionary dictionaryWithDictionary:replaced];
}

@end
