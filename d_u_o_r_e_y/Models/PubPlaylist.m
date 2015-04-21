//
//  PubPlaylist.m
//  Duorey
//
//  Created by lixu on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PubPlaylist.h"

@implementation PubPlaylist

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"allData":@"data",
             @"playlistObj":@"data_list",
             @"isFlow":@"isFlow",
             @"isDing":@"isDing"
             };
}

+ (NSValueTransformer *)allDataJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[PlaylistDetail class]];
}

+ (NSValueTransformer *)playlistObjJSONTransformer{
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
