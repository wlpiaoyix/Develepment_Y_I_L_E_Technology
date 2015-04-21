//
//  MainViewObj.m
//  Duorey
//
//  Created by lixu on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "MainViewObj.h"

@implementation MainViewObj

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"listId":@"lid",
             @"listName":@"list_name",
             @"listenCount":@"ting_num",
             @"listIcon":@"list_ico"
             };
}

+ (NSValueTransformer *)listIdJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

+ (NSValueTransformer *)listenCountJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

@end
