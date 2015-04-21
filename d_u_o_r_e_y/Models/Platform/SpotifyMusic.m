//
//  SpotifyObj.m
//  Duorey
//
//  Created by lixu on 14/11/6.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "SpotifyMusic.h"
#import "PTUtilities.h"

@interface SpotifyMusic()

@property (nonatomic, strong, readonly) NSNumber *timeLengthNormal;

@end


@implementation SpotifyMusic

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"songName":@"name",
             @"songUrl":@"uri",
             @"meid":@"id",
             @"style":@"type",
             @"timeLengthNormal":@"duration_ms",
             @"album":@"album.name",
             @"iconBig":@"album.images[0].url",
             @"iconSmall":@"album.images[1].url",
             @"iconNormal":@"album.images[2].url",
             @"pubYear":@"created_at",
             @"singer":@"artists.name",
             @"musicLang":@""
             };
}

+ (NSValueTransformer *)iconBigJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)iconSmallJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)iconNormalJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)songUrlJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)timeLengthNormalJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

- (MusicSource)source{
    return MusicSourceSpotify;
}

- (MediaSource)type{
    return MediaSourceAudio;
}

- (NSString *)typeString{
    if (self.type == MediaSourceAudio) {
        return @"M";
    }else{
        return @"V";
    }
}

- (NSNumber *)timeLength{
    return [NSNumber numberWithInt:[self.timeLengthNormal intValue] / 1000];
}

- (NSString *)price {
    return @"";
}

- (NSURL *)purchaseUrl {
    return nil;
}
@end
