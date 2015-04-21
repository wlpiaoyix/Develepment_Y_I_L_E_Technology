//
//  ActivityObj.m
//  Duorey
//
//  Created by ice on 14/11/27.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ActivityObj.h"

@implementation ActivityObj


+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"creatTime":@"createtime",
             @"activityType":@"action",
             @"music":@"source",
             @"followUser":@"flow_user",
             @"playList":@"list",
             @"user":@"user",
             };
}

+ (NSValueTransformer *)musicJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[Music class]];
}
+ (NSValueTransformer *)playListJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[PlaylistObj class]];
}
+ (NSValueTransformer *)followUserJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[UserAccount class]];
}
+ (NSValueTransformer *)userJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[UserAccount class]];
}
//+ (NSValueTransformer *)userJSONTransformer{
//    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[UserAccount class]];
//}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}
@end
