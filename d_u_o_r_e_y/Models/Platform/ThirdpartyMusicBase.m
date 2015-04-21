//
//  ThirdpartyMusicBase.m
//  Duorey
//
//  Created by xdy on 15/3/13.
//  Copyright (c) 2015年 www.yileapp.com. All rights reserved.
//

#import "ThirdpartyMusicBase.h"

@implementation ThirdpartyMusicBase

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

- (NSDictionary *)duoreySystemMusicDictionary{
    UserAccount *user = [PTUtilities readLoginUser];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    if ([user.userId isKindOfClass:[NSString class]]) {
        [dic setObject:user.userId forKey:@"uid"];
//    } else {
//        [dic setObject:[user.userId stringValue] forKey:@"uid"];
//    }
    [dic setObject:user.userToken forKey:@"token"];
    [dic setObject:self.songName forKey:@"name"];
    [dic setObject:self.meid forKey:@"meid"];
    [dic setObject:[NSNumber numberWithInt:self.source] forKey:@"eid"];
    [dic setObject:self.typeString forKey:@"source_type"];
    [dic setObject:[self.songUrl absoluteString] forKey:@"url"];
    
    
    if (![PTUtilities isEmptyOrNull:self.album]){
        [dic setObject:self.album forKey:@"album"];
    }
    
    if (![PTUtilities isEmptyOrNull:self.style]){
        [dic setObject:self.style forKey:@"style"];
    }
    
    [dic setObject:self.timeLength forKey:@"time_length"];
    
    if(![PTUtilities isEmptyOrNull:[self.iconBigURL absoluteString]]){
        [dic setObject:[self.iconBigURL absoluteString] forKey:@"ico_big"];
    }
    
    if(![PTUtilities isEmptyOrNull:[self.iconSmallURL absoluteString]]){
        [dic setObject:[self.iconSmallURL absoluteString] forKey:@"ico_small"];
    }
    
    if(![PTUtilities isEmptyOrNull:[self.iconNormalURL absoluteString]]){
        [dic setObject:[self.iconNormalURL absoluteString] forKey:@"ico_nomal"];
    }
    
    if (![PTUtilities isEmptyOrNull:self.pubYear]){
        [dic setObject:self.pubYear forKey:@"pub_year"];
    }
    
    if (![PTUtilities isEmptyOrNull:self.singer]){
        [dic setObject:self.singer forKey:@"singer"];
    }
    
    if(![PTUtilities isEmptyOrNull:self.musicLang]){
        [dic setObject:self.musicLang forKey:@"music_lang"];
    }
    
    if(![PTUtilities isEmptyOrNull:self.purchaseUrl]){
        [dic setObject:self.purchaseUrl forKey:@"buy_url"];
    }
    return dic;
}

- (Music *)duoreyMusicModel{
    Music *music = [[Music alloc] init];
    music.trackName = self.songName;
    music.trackId = self.meid;
    music.trackURL = self.songUrl;
    music.genreName = self.style;
    music.source = self.source;
    music.type = self.type;
    music.trackTime = self.timeLength;
    music.albumName = self.album;
    music.artistName = self.singer;
    music.artworkUrlBigger = self.iconBigURL;
    music.artworkUrlMini = self.iconSmallURL;
    music.artworkUrlNormal = self.iconNormalURL;
    music.pubYear = self.pubYear;
    music.musicLang = self.musicLang;
    music.audioFileURL = self.songUrl;
    music.purchaseUrl = self.purchaseUrl;
    return music;
}

@end
