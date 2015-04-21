//
//  PTEnum.h
//  PhonTunes
//
//  Created by xdy on 14-1-9.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#ifndef PhonTunes_PTEnum_h
#define PhonTunes_PTEnum_h

typedef NS_ENUM (NSUInteger, UserType){
    UserTypeSystem = 1,
    UserTypeTwitter,
    UserTypeFacebook
};

typedef NS_ENUM (NSUInteger, ConnectService){
    ConnectServiceSpotify = 1,
    ConnectServiceRdio,
    ConnectServiceSoundCloud
};

typedef NS_ENUM (NSUInteger, PTTrackLevel){
	PTTrackLevelLow,
    PTTrackLevelMedium,
	PTTrackLevelHigh
};

typedef NS_ENUM (NSUInteger, MusicSource){
	MusicSourceiTunes=1,
    MusicSourceSpotify,
    MusicSourceRdio,
    MusicSourceSoundCloud
};

typedef NS_ENUM (NSUInteger, MediaSource){
    MediaSourceVideo=1,
    MediaSourceAudio
};

typedef NS_ENUM (NSUInteger,PTShareSocialType){
    PTShareSocialTypeFacebook,
    PTShareSocialTypeTwitter
};

typedef NS_ENUM (NSUInteger, UserFollowType){
    UserFollowTypeFollow=1,
    UserFollowTypeFollowed
};
#endif
