//
//  OtherUserProfile.m
//  Duorey
//
//  Created by xdy on 14/11/25.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "OtherUserProfile.h"

@implementation OtherUserProfile

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"userAccount":@"user",
             @"feedPlaylists":@"feed_playlist",
             @"followed":@"isflow"
             };
}

+ (NSValueTransformer *)feedPlaylistsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[PlaylistObj class]];
}

+ (NSValueTransformer *)userAccountJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[UserAccount class]];
}

//+ (NSValueTransformer *)followedJSONTransformer{
//    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
//                                                                           @"0":@(0),
//                                                                           @"1":@(1)
//                                                                           }];
//}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

@end
