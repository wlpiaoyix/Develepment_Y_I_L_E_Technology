//
//  RidoObj.m
//  Duorey
//
//  Created by lixu on 14/11/6.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "RidoMusic.h"

@interface RidoMusic ()

@property (nonatomic, strong, readonly) NSNumber *timeLengthNormal;

@end

@implementation RidoMusic

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"songName":@"name",
             @"songUrl":@"url",
             @"meid":@"key",
             @"style":@"type",
             @"timeLengthNormal":@"duration",
             @"album":@"album",
             @"iconBig":@"icon400",
             @"iconSmall":@"icon200",
             @"iconNormal":@"gridIcon",
             @"pubYear":@"created_at",
             @"singer":@"artist",
             };
}

+ (NSValueTransformer *)iconBigJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)iconSamllJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)iconNomalJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)songUrlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)timeLengthNormalJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

- (NSNumber *)timeLength{
    return [NSNumber numberWithInt:[self.timeLengthNormal intValue] / 1000];
}

- (MusicSource)source {
    return MusicSourceRdio;
}

- (MediaSource)type {
    return MediaSourceAudio;
}

- (NSString *)typeString {
    if (self.type == MediaSourceAudio) {
        return @"M";
    }else{
        return @"V";
    }
}

- (NSString *)price {
    return @"";
}

- (NSURL *)purchaseUrl {
    return nil;
}

@end
