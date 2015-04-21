//
//  PlaylistDetail.m
//  Duorey
//
//  Created by lixu on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistDetail.h"
#import "Music.h"
#import "UserAccount.h"

@implementation PlaylistDetail

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"music":@"music",
             @"userAccount":@"user"
             };
}

+ (NSValueTransformer *)musicJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[Music class]];
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
