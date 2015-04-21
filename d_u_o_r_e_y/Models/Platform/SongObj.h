//
//  SongObj.h
//  Duorey
//
//  Created by lixu on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ImportPlaylist.h"
#import <AFNetworking.h>
#import "RssAppleMusic.h"

@interface SongObj : NSObject {
    
}

- (AFHTTPRequestOperation *)doSpotifySearchWithKey:(NSString *)searchKey
                                        completion:(void(^)(NSArray *values,NSError *error))block;
- (AFHTTPRequestOperation *)doSoundCloudSearchWithKey:(NSString *)searchKey
                                           completion:(void(^)(NSArray *values,NSError *error))block;
- (AFHTTPRequestOperation *)doItunesSearchWithKey:(NSString *)searchKey
                                       completion:(void(^)(NSArray *values,NSError *error))block;
//get soundcloud playlist
- (AFHTTPRequestOperation *)getSoundCloudUserPlaylistCompletion:(void(^)(ImportPlaylist *importPlaylist,NSError *error))block;

+ (AFHTTPRequestOperation *)getItunesMainValueWithCount:(NSInteger)limit
                                             completion:(void(^)(NSArray *values,NSError *error))block;
@end
