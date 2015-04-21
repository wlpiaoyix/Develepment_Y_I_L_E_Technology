//
//  SelfUserProfile.m
//  Duorey
//
//  Created by xdy on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "SelfUserProfile.h"

@implementation SelfUserProfile

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"userAccount":@"user",
             @"recentArray":@"recent",
             @"recentWeekArray":@"recent_week"
             };
}

+ (NSValueTransformer *)recentArrayJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[Music class]];
}

+ (NSValueTransformer *)recentWeekArrayJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[Music class]];
}

+ (NSValueTransformer *)userAccountJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[UserAccount class]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}
@end
