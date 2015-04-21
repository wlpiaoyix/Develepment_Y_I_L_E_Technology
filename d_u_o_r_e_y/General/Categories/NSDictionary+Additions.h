//
//  NSDictionary+Additions.h
//  Duorey
//
//  Created by yong on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

- (NSDictionary *)nestedDictionaryByReplacingNullsWithNil:(NSDictionary*)sourceDictionary;

@end
