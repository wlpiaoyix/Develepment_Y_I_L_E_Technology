//
//  SongObj.m
//  Duorey
//
//  Created by lixu on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "SongObj.h"
#import "SpotifyMusic.h"
#import "SoundCloudMusic.h"
#import "AppDelegate.h"
#import "PTUtilities.h"
#import "RidoMusic.h"
#import "MainItunesObj.h"
#import "ImportMusic.h"
#import "ImportSongObj.h"
#import <UALogger.h>
#import "PTAppClientEngine.h"
#import "Search.h"
#import "RssAppleMusic.h"
#import "SearchAppleMusic.h"

@implementation SongObj

#pragma mark do search
- (AFHTTPRequestOperation *)doSpotifySearchWithKey:(NSString *)searchKey
                                        completion:(void(^)(NSArray *values,NSError *error))block
{
    NSString *baseUrlStr = @"https://api.spotify.com/v1/search?";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:searchKey forKey:@"q"];
    [dic setObject:@"track" forKey:@"type"];
    [dic setObject:@"20" forKey:@"limit"];
    AFHTTPRequestOperationManager *httpClient = [[AFHTTPRequestOperationManager alloc]
                                                         initWithBaseURL:[NSURL URLWithString:baseUrlStr]];
    return [httpClient GET:baseUrlStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray *spotifys = [MTLJSONAdapter modelsOfClass:SpotifyMusic.class
                                            fromJSONArray:[[responseObject objectForKey:@"tracks"] objectForKey:@"items"] error:nil];
        if (block) {
            block(spotifys,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        UALog(@"Error: %@",error);
//        block(nil,error);
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (AFHTTPRequestOperation *)getSoundCloudUserPlaylistCompletion:(void(^)(ImportPlaylist *importPlaylist,NSError *error))block{
    NSString *baseUrlStr = @"https://api.soundcloud.com/me/playlists.json?";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    UserAccount *userAccount = [PTUtilities readLoginUser];
    [dic setObject:userAccount.soundCloudAccount.accessToken forKey:@"oauth_token"];
    AFHTTPRequestOperationManager *httpClient = [[AFHTTPRequestOperationManager alloc]
                                                 initWithBaseURL:[NSURL URLWithString:baseUrlStr]];
    return [httpClient GET:baseUrlStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject){
        UALog(@"----%@",responseObject);
        
        ImportPlaylist *importPlaylist = [[ImportPlaylist alloc] init];
        NSMutableArray *datas = [[NSMutableArray alloc] init];
        for (NSDictionary *allDic in responseObject) {
            ImportMusic *importMusic = [[ImportMusic alloc] init];
            
            PlaylistObj *playlistObj = [[PlaylistObj alloc] init];
            playlistObj.listName=[allDic objectForKey:@"title"];
            playlistObj.extId=[allDic objectForKey:@"id"];
            playlistObj.category=[NSNumber numberWithInt:4];
            playlistObj.totalNum=[allDic objectForKey:@"track_count"];
//            playlistObj.listIcon=[PTUtilities returnImageURLStrWithStr:[[[allDic objectForKey:@"tracks"] objectAtIndex:0] objectForKey:@"artwork_url"]
//                                                               withKey:@"large"
//                                                              withSize:@"t500x500"];
//            playlistObj.modifyTime=[allDic objectForKey:@"last_modified"];
            playlistObj.comments=[allDic objectForKey:@"description"];
            importMusic.playlist=playlistObj;
            
            NSMutableArray *musicArr = [[NSMutableArray alloc] init];
            for (int i=0;i<[[allDic objectForKey:@"tracks"] count];i++) {
                ImportSongObj *music = [[ImportSongObj alloc] init];
                NSDictionary *dic = [[allDic objectForKey:@"tracks"] objectAtIndex:i];
                music.trackName  = [dic objectForKey:@"title"];
                music.trackURL  = [NSURL URLWithString:[dic objectForKey:@"stream_url"]];
                music.source  = MusicSourceSoundCloud;
                music.type  = MediaSourceAudio;
                music.albumName=@"SoundCloud";
                music.artistName=[[dic objectForKey:@"user"] objectForKey:@"username"];
                music.genreName = [dic objectForKey:@"genre"];
                music.trackId = [dic objectForKey:@"id"];
                music.trackTime  = [NSNumber numberWithInt:[[dic objectForKey:@"duration"] intValue]/1000];
                if (![PTUtilities isEmptyOrNull:[dic objectForKey:@"artwork_url"]]) {
                    music.artworkUrlMini  = [PTUtilities returnImageURLWithStr:[dic objectForKey:@"artwork_url"]
                                                                       withKey:@"large"
                                                                      withSize:@"large"];
                    music.artworkUrlNormal  = [PTUtilities returnImageURLWithStr:[dic objectForKey:@"artwork_url"]
                                                                         withKey:@"large"
                                                                        withSize:@"t300x300"];
                    music.artworkUrlBigger  = [PTUtilities returnImageURLWithStr:[dic objectForKey:@"artwork_url"]
                                                                         withKey:@"large"
                                                                        withSize:@"t500x500"];
                }
                music.pubYear  = [dic objectForKey:@"created_at"];
                music.ower  = [dic objectForKey:userAccount.userId];
                [musicArr addObject:music];
            }
            importMusic.musicArr=musicArr;
            [datas addObject:importMusic];
        }
        importPlaylist.importMusics=datas;
        importPlaylist.userId=userAccount.userId;
        importPlaylist.token=userAccount.userToken;
        importPlaylist.source=4;
        if (block) {
            block(importPlaylist,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        UALog(@"Error: %@",error);
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//- (AFHTTPRequestOperation *)doSoundCloudSearchWithKey:(NSString *)searchKey
//                                           completion:(void(^)(NSArray *values,NSError *error))block{
//    NSString *baseUrlStr = @"http://api.soundcloud.com/tracks.json?";
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:@"0f59b312672b4d4231dd9aafcb0ba44d" forKey:@"client_id"];
//    [dic setObject:searchKey forKey:@"q"];
//    UserAccount *userAccount = [PTUtilities readLoginUser];
//    [dic setObject:userAccount.soundCloudAccount.accessToken forKey:@"access_token"];
//    [dic setObject:@"track" forKey:@"type"]; //  album,artist,track
//    [dic setObject:@"30" forKey:@"limit"];
//    [dic setObject:@"public" forKey:@"filter"];
////    [dic setObject:@"cc-by-sa" forKey:@"licence"];
//    AFHTTPRequestOperationManager *httpClient = [[AFHTTPRequestOperationManager alloc]
//                                                 initWithBaseURL:[NSURL URLWithString:baseUrlStr]];
//    return [httpClient GET:baseUrlStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject){
//        NSArray *soundClouds = [MTLJSONAdapter modelsOfClass:SoundCloudObj.class
//                                               fromJSONArray:responseObject error:nil];
//        NSArray *validClouds = [soundClouds filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"songUrl != nil"]];
//        if (block) {
//            block(validClouds,nil);
//        }
//    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
//        UALog(@"Error: %@",error);
////        block(nil,error);
//        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
//        }
//    }];
//}

- (AFHTTPRequestOperation *)doItunesSearchWithKey:(NSString *)searchKey
                        completion:(void(^)(NSArray *values,NSError *error))block{
    NSString *baseUrlStr = @"https://itunes.apple.com/search?";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:searchKey forKey:@"term"];
    [dic setObject:@"music" forKey:@"media"];
    [dic setObject:@"30" forKey:@"limit"];
    AFHTTPRequestOperationManager *httpClient = [[AFHTTPRequestOperationManager alloc]
                                                 initWithBaseURL:[NSURL URLWithString:baseUrlStr]];
    return [httpClient GET:baseUrlStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray *itunes = [MTLJSONAdapter modelsOfClass:SearchAppleMusic.class
                                          fromJSONArray:[responseObject objectForKey:@"results"] error:nil];
        if (block) {
            block(itunes,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
//        block(nil,error);
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

+ (AFHTTPRequestOperation *)getItunesMainValueWithCount:(NSInteger)limit
                                             completion:(void(^)(NSArray *values,NSError *error))block{
    
    NSString *baseUrlStr = [NSString stringWithFormat:@"https://itunes.apple.com/us/rss/topsongs/limit=%d/json",(int)limit];
    AFHTTPRequestOperationManager *httpClient = [[AFHTTPRequestOperationManager alloc]
                                                 initWithBaseURL:[NSURL URLWithString:baseUrlStr]];
    return [httpClient GET:baseUrlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray *allArr = [MTLJSONAdapter modelsOfClass:RssAppleMusic.class fromJSONArray:[[responseObject objectForKey:@"feed"] objectForKey:@"entry"] error:nil];
        if (block) {
            block(allArr,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

#pragma soundcloud search

- (AFHTTPRequestOperation *)doSoundCloudSearchWithKey:(NSString *)searchKey
                                           completion:(void(^)(NSArray *values,NSError *error))block{
    NSString *baseUrlStr = @"http://api.soundcloud.com/tracks.json?";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"0f59b312672b4d4231dd9aafcb0ba44d" forKey:@"client_id"];
    [dic setObject:searchKey forKey:@"q"];
//    UserAccount *userAccount = [PTUtilities readLoginUser];
//    [dic setObject:userAccount.soundCloudAccount.accessToken forKey:@"access_token"];
    [dic setObject:@"track" forKey:@"type"]; //  album,artist,track
    [dic setObject:@"30" forKey:@"limit"];
//    [dic setObject:@"public" forKey:@"filter"];
    //    [dic setObject:@"cc-by-sa" forKey:@"licence"];
    AFHTTPRequestOperationManager *httpClient = [[AFHTTPRequestOperationManager alloc]
                                                 initWithBaseURL:[NSURL URLWithString:baseUrlStr]];
    return [httpClient GET:baseUrlStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray *soundClouds = [MTLJSONAdapter modelsOfClass:SoundCloudMusic.class
                                               fromJSONArray:responseObject error:nil];
        NSArray *validClouds = [soundClouds filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"songUrl != nil"]];
        if (block) {
            block(validClouds,nil);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        UALog(@"Error: %@",error);
        //        block(nil,error);
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

@end
