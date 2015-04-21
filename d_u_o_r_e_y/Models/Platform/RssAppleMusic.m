//
//  RssAppleMusic.m
//  Duorey
//
//  Created by xdy on 15/3/12.
//  Copyright (c) 2015年 www.yileapp.com. All rights reserved.
//

#import "RssAppleMusic.h"

@interface RssAppleMusic()

@property (nonatomic, strong, readonly) NSArray *links;
@property (nonatomic, strong, readonly) NSArray *images;
@property (nonatomic, strong, readonly) NSArray *durations;
@property (nonatomic, copy, readonly) NSString *priceString;
@end

@implementation RssAppleMusic

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"songName":@"im:name.label",
             @"meid":@"id.attributes.im:id",
             @"style":@"category.attributes.label",
             @"album":@"im:collection.im:name.label",
             @"priceString":@"im:price.label",
             @"pubYear":@"im:releaseDate.label",
             @"singer":@"im:artist.label",
//             @"purchaseUrl":@"link.attributes.href",
//             @"songUrl":@"link.attributes.href",
             @"links":@"link.attributes.href",
//             @"iconBig":@"im:image.label",
//             @"iconSmall":@"im:image.label",
//             @"iconNomal":@"im:image.label"
             @"images":@"im:image.label",
//             @"timeLength":@"link.im:duration.label",
             @"durations":@"link.im:duration.label"
             };
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

- (NSString *)musicLang{
    return @"";
}

- (NSNumber *)price{
    return [NSNumber numberWithFloat:[[self.priceString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"฿₵¢₡B/.₫€ƒ₲Kč₭£₤₥₦₱PRRM₨₽SkS/.৳R$$₮₩¥zł₴₪"]] floatValue]];
}

- (NSString *)purchaseUrl{
    return [self.links firstObject];
}

- (NSURL *)songUrl{
    NSString *temp = [self.links lastObject];
    if (!temp && [temp isEmpty]) {
        return nil;
    }
    return [NSURL URLWithString:temp];
}

- (NSURL *)iconBigURL{
    NSString *bigUrlString = [PTUtilities returnImageURLStrWithStr:[self.images lastObject]
                                                           withKey:@"170x170"
                                                          withSize:@"600x600"];
    if (!bigUrlString && [bigUrlString isEmpty]) {
        return nil;
    }
    return [NSURL URLWithString:bigUrlString];
}

- (NSURL *)iconNormalURL{
    NSString *normalUrlString = [PTUtilities returnImageURLStrWithStr:[self.images lastObject]
                                                           withKey:@"170x170"
                                                          withSize:@"400x400"];
    if (!normalUrlString && [normalUrlString isEmpty]) {
        return nil;
    }
    return [NSURL URLWithString:normalUrlString];
}

- (NSURL *)iconSmallURL{
    NSString *smallUrlString = [PTUtilities returnImageURLStrWithStr:[self.images lastObject]
                                                           withKey:@"170x170"
                                                          withSize:@"200x200"];
    if (!smallUrlString && [smallUrlString isEmpty]) {
        return nil;
    }
    return [NSURL URLWithString:smallUrlString];
}

- (NSNumber *)timeLength{
    NSString *timeString = [self.durations lastObject];
    if (timeString && ![timeString isEmpty]) {
        return [NSNumber numberWithInt:[timeString intValue] / 1000];
    }
    
    return [NSNumber numberWithInt:0];
}
@end
