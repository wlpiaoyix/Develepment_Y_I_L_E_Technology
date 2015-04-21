//
//  YLAudioPlayer.h
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>
#import "PTDefinitions.h"
#import <Rdio/Rdio.h>
#import "Music.h"
#import <SCAPI.h>

static NSString * const MusicRepeatKey = @"com.yile.audio.repeat";

typedef NS_ENUM(NSInteger, MusicPlaybackState){
    MusicPlaybackStateLoading,
    MusicPlaybackStatePlaying,
    MusicPlaybackStatePaused,
    MusicPlaybackStateError
};

typedef NS_ENUM(NSInteger, MusicRepeatModel){
    MusicRepeatModelDefault=0,
    MusicRepeatModelLoop,
    MusicRepeatModelShuffle
};

@class YLAudioPlayer;

@protocol YLAudioPlayerDelegate <NSObject>

@required
- (void)audioPlayer:(YLAudioPlayer *)audioPlayer currentPlayMusic:(Music *)currentMusic;
- (void)audioPlayer:(YLAudioPlayer *)audioPlayer durationUpdate:(CGFloat)duration currentTimeUpdate:(CGFloat)currentTime;
- (void)audioPlayer:(YLAudioPlayer *)audioPlayer listCount:(NSInteger)count currentIndex:(NSInteger)index;

@optional
- (void)audioPlayerStartLoading:(YLAudioPlayer *)audioPlayer;
- (void)audioPlayerStartPlaying:(YLAudioPlayer *)audioPlayer;
- (void)audioPlayerStartPause:(YLAudioPlayer *)audioPlayer;
- (void)audioPlayerError:(YLAudioPlayer *)audioPlayer message:(NSString *)msg;
- (void)audioPlayer:(YLAudioPlayer *)audioPlayer currentTrackFinished:(BOOL)finished;
@end

@interface YLAudioPlayer : NSObject

@property (weak, nonatomic) id<YLAudioPlayerDelegate> delegate;

@property (nonatomic, assign, readonly) MusicPlaybackState playbackState;
@property (nonatomic) NSInteger currentTrack;
@property (nonatomic) MusicRepeatModel repeatModel;
@property (nonatomic,readonly,getter=isPlaying) BOOL playing;

//@property (nonatomic, assign) BOOL shouldStopProfileCellPlayView; //外部播放的时候，停止profile里面的cell play view的播放
@property (nonatomic, assign) NSString *currentPlayingPlaylistId; //当前正在播放的播放列表id

+ (instancetype)sharedAudioPlayer;

- (void)playCurrentTrack:(Music *)music;
- (void)playTracks:(NSArray *)musics startIndex:(NSInteger)currentInext;
- (void)audioPlayerDidSeekToPosition:(CGFloat)position;

- (void)addMusics:(NSArray *)musics;
- (NSInteger)musicListCount;
- (void)reloadData;
- (void)reloadDataPlay;
- (Music *)currentPlayMusic;
- (Music *)objectAtIndex:(NSInteger)index;
- (NSString *)currentMusicID;

-(void)play;
-(void)pause;
-(void)next;
-(void)previous;
-(void)stopPlay;//for logout
@end
