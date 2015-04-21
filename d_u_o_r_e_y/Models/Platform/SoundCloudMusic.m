//
//  SoundCloudObj.m
//  Duorey
//
//  Created by lixu on 14/11/6.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "SoundCloudMusic.h"

@interface SoundCloudMusic()

@property (nonatomic, strong, readonly) NSNumber *timeLengthNormal;
@property (nonatomic, copy, readonly) NSString *iconBigUrlString;

@end

@implementation SoundCloudMusic

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"songName":@"title",
             @"songUrl":@"stream_url",
             @"meid":@"id",
             @"style":@"",
             @"timeLengthNormal":@"duration",
             @"iconBigUrlString":@"artwork_url",
             @"pubYear":@"last_modified",
             @"singer":@"user.username",
             @"musicLang":@""
             };
}

- (MusicSource)source{
    return MusicSourceSoundCloud;
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

- (NSString *)album{
    return @"SoundCloud";
}

- (NSURL *)iconBigURL{
    if (!self.iconBigUrlString && [self.iconBigUrlString isEmpty]) {
        return nil;
    }
    NSString *urlBigStr = [PTUtilities returnImageURLStrWithStr:self.iconBigUrlString
                                                          withKey:@"large"
                                                         withSize:@"large"];
    
    return [NSURL URLWithString:urlBigStr];
}

- (NSURL *)iconSmallURL{
    if (!self.iconBigUrlString && [self.iconBigUrlString isEmpty]) {
        return nil;
    }
    NSString *urlSmallStr = [PTUtilities returnImageURLStrWithStr:self.iconBigUrlString
                                                           withKey:@"large"
                                                          withSize:@"t300x300"];
    
    return [NSURL URLWithString:urlSmallStr];
}

- (NSURL *)iconNormalURL{
    if (!self.iconBigUrlString && [self.iconBigUrlString isEmpty]) {
        return nil;
    }
    NSString *urlNormalStr = [PTUtilities returnImageURLStrWithStr:self.iconBigUrlString
                                                          withKey:@"large"
                                                         withSize:@"t500x500"];
    
    return [NSURL URLWithString:urlNormalStr];
}

+ (NSValueTransformer *)songUrlJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)timeLengthNormalJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

- (NSString *)price {
    return @"";
}

- (NSURL *)purchaseUrl {
    return nil;
}

- (NSNumber *)timeLength{
    return [NSNumber numberWithInt:[self.timeLengthNormal intValue] / 1000];
}
@end
