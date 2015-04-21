//
//  ItunesObj.m
//  Duorey
//
//  Created by lixu on 14/11/19.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "SearchAppleMusic.h"

@interface SearchAppleMusic()

@property (nonatomic, strong, readonly) NSNumber *timeLengthNormal;
@property (nonatomic, copy, readonly) NSString *iconBigUrlString;

@end

@implementation SearchAppleMusic

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"songName":@"trackName",
             @"songUrl":@"previewUrl",
             @"meid":@"trackId",
             @"style":@"primaryGenreName",
             @"timeLengthNormal":@"trackTimeMillis",
             @"album":@"collectionName",
             @"iconBigUrlString":@"artworkUrl100",
             @"pubYear":@"releaseDate",
             @"singer":@"artistName",
             @"musicLang":@"",
             @"purchaseUrl":@"trackViewUrl",
             @"price":@"trackPrice"
             };
}

- (NSURL *)iconBigURL{
    NSString *bigUrlString = [PTUtilities returnImageURLStrWithStr:self.iconBigUrlString
                                                           withKey:@"100x100"
                                                          withSize:@"600x600"];
    if (!bigUrlString && [bigUrlString isEmpty]) {
        return nil;
    }
    return [NSURL URLWithString:bigUrlString];
}

- (NSURL *)iconNormalURL{
    NSString *smallUrlString = [PTUtilities returnImageURLStrWithStr:self.iconBigUrlString
                                                           withKey:@"100x100"
                                                          withSize:@"400x400"];
    if (!smallUrlString && [smallUrlString isEmpty]) {
        return nil;
    }
    return [NSURL URLWithString:smallUrlString];
}

- (NSURL *)iconSmallURL{
    NSString *normalUrlString = [PTUtilities returnImageURLStrWithStr:self.iconBigUrlString
                                                           withKey:@"100x100"
                                                          withSize:@"200x200"];
    if (!normalUrlString && [normalUrlString isEmpty]) {
        return nil;
    }
    return [NSURL URLWithString:normalUrlString];
}

+ (NSValueTransformer *)songUrlJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)timeLengthNormalJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

- (MusicSource)source{
    return MusicSourceiTunes;
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
@end
