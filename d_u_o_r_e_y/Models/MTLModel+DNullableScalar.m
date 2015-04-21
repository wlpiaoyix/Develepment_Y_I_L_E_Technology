//
//  MTLModel+DNullableScalar.m
//  Duorey
//
//  Created by xdy on 14/11/8.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "MTLModel+DNullableScalar.h"

@implementation MTLModel (DNullableScalar)

- (void)setNilValueForKey:(NSString *)key{
    [self setValue:@0 forKey:key];
}

@end
