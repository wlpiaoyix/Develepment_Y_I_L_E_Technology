//
//  ImportSongObj.m
//  Duorey
//
//  Created by lixu on 14/12/18.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ImportSongObj.h"

@implementation ImportSongObj

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"sid":@"sid",
             @"trackName":@"name",
             @"trackId":@"meid",
             @"trackURL":@"url",
             @"genreName":@"style",
             @"artworkUrlMini":@"ico_small",
             @"artworkUrlNormal":@"ico_nomal",
             @"artworkUrlBigger":@"ico_big",
             @"source":@"eid",
             @"type":@"source_type",
             @"trackTime":@"time_length",
             @"albumName":@"album",
             @"artistName":@"singer",
             @"pubYear":@"pub_year",
             @"createrId":@"creater",
             @"musicLang":@"music_lang",
             @"ower":@"ower"
             };
}

+ (NSValueTransformer *)artworkUrlMiniJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)artworkUrlNormalJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)artworkUrlBiggerJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)trackURLJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)audioFileURLJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)sourceJSONTransformer{
    //    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"1":@(MusicSourceiTunes),
                                                                           @"2":@(MusicSourceSpotify),
                                                                           @"3":@(MusicSourceRdio),
                                                                           @"4":@(MusicSourceSoundCloud)
                                                                           }];
}

+ (NSValueTransformer *)typeJSONTransformer{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"M":@(MediaSourceAudio),
                                                                           @"V":@(MediaSourceVideo)
                                                                           }];
}

+ (NSValueTransformer *)trackTimeJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

+ (NSValueTransformer *)albumNameJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLStringValueTransformerName];
}

+ (NSValueTransformer *)artistNameJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLStringValueTransformerName];
}

+ (NSValueTransformer *)trackNameJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLStringValueTransformerName];
}

+ (NSValueTransformer *)trackIdJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLStringValueTransformerName];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

@end

