//
//  ImportPlaylist.m
//  Duorey
//
//  Created by lixu on 14/12/2.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ImportPlaylist.h"

@implementation ImportPlaylist

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"importMusics":@"data",
             @"userId":@"uid",
             @"token":@"token",
             @"source":@"source"
             };
}

+ (NSValueTransformer *)importMusicsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[ImportMusic class]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}
@end
