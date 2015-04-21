//
//  ImportMusic.m
//  Duorey
//
//  Created by lixu on 14/12/2.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ImportMusic.h"
#import "Music.h"

@implementation ImportMusic

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"playlist":@"playlist",
             @"musicArr":@"items"
             };
}

+ (NSValueTransformer *)musicArrJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[Music class]];
}

+ (NSValueTransformer *)playlistJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[PlaylistObj class]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

@end
