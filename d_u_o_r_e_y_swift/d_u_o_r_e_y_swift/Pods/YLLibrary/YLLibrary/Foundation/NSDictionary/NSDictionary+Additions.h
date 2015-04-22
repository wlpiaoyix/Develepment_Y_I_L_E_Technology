//
//  NSDictionary+Additions.h
//  Duorey
//
//  Created by yong on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

/**
 *  返回一个去掉null值的新字典
 *
 *  @param sourceDictionary 没有去掉null值的字典
 *
 *  @return 已经去掉null值的字典
 */
- (NSDictionary *)nestedDictionaryByReplacingNullsWithNil:(NSDictionary*)sourceDictionary;

@end
