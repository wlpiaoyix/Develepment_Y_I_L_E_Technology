//
//  YLAudioPlayer.m
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "YLAudioPlayer.h"
#import <UALogger.h>
#import <AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+Path.h"
#import "NSString+Hash.h"
#import "UIImage+Compress.h"
#import "UserAccount.h"
#import "PTUtilities.h"
#import "AuthorizationViewController.h"
#import "NSString+Additions.h"
#import "PTAppClientEngine.h"
#import "HysteriaPlayer.h"
#import <NXOAuth2Request.h>
#import "ConnectServiceViewController.h"
#import "UIImageView+WebCache.h"

static NSString * const YL_ERROR_DOMAIN    = @"com.yile.audio.player.domain.error";
static NSString * const YL_AUDIOPLAYER_ENTERBEGORAD    = @"com.yile.audio.player.enter.begorad";
static NSString * const kAudioPlayerLockName = @"com.yile.audio.operation.lock";

static NSString * const YL_PlaylistObject_Key = @"PTPlaylistObjectID";
static NSString * const YL_PlaylistIndex_Key = @"PTPlayingTrackObjectID";
static NSString * const YL_FILE_NAME = @"YL_Player_File";

static void *kDouAudioStreamerStatusKVOKey = &kDouAudioStreamerStatusKVOKey;
static void *kDouAudioStreamerDurationKVOKey = &kDouAudioStreamerDurationKVOKey;

static void *kRdioDurationKVOKey = &kRdioDurationKVOKey;
static void *kSystemPlayerDurationKVOKey = &kSystemPlayerDurationKVOKey;


@interface YLAudioPlayer()<SPTAudioStreamingPlaybackDelegate,SPTAudioStreamingDelegate,RdioDelegate,RDPlayerDelegate,UIAlertViewDelegate, HysteriaPlayerDelegate,AVAudioSessionDelegate>{
    HysteriaPlayer *_streamPlayer;
    AVAudioPlayer *_systemPlayer;
    SPTAudioStreamingController *_spotifyPlayer;
    Rdio *_rdioPlayer;
    Music *_music;
    NSArray *_musics;
    NSTimer *_timer;
//    BOOL _firstLoad;
    NSRecursiveLock *_lock;
    BOOL _hysteriaPlayerFirst;
    NXOAuth2Request *_soundCloudRequest;
    NSInteger _errorCount;
    UIImageView *_loadCoverImageView;
    BOOL _interruptedWhilePlaying;
    BOOL _routeChangedWhilePlaying;
}

@end

@implementation YLAudioPlayer
- (instancetype)init{
    self = [super init];
    
    if (self) {
        _playbackState = MusicPlaybackStatePaused;
        _currentTrack = 0;
        _repeatModel = DEFAULTS(integer, MusicRepeatKey);
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = kAudioPlayerLockName;
        _errorCount = 0;
//        _firstLoad = YES;

        _loadCoverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        [session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
        NSError *activationError = nil;
        [session setActive:YES error:&activationError];
        
        addNotificationObserver(UIApplicationDidEnterBackgroundNotification, self, @selector(saveCode), nil);
//        addNotificationObserver(AVAudioSessionInterruptionNotification, self, @selector(interruption:), nil);
//        addNotificationObserver(AVAudioSessionRouteChangeNotification, self, @selector(routeChange:), nil);
//        SET_DEFAULTS(Bool, ForcePausePlayer, NO);
        
        if (!_musics) {
            if (DEFAULTS(bool, YL_AUDIOPLAYER_ENTERBEGORAD)) {
                [self loadCode];
            }
        }
    }
    
    return self;
}

- (void)dealloc{
    removeNotificationObserver(UIApplicationDidEnterBackgroundNotification, self, nil);
//    removeNotificationObserver(AVAudioSessionInterruptionNotification, self, nil);
//    removeNotificationObserver(AVAudioSessionRouteChangeNotification, self, nil);
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

+ (instancetype)sharedAudioPlayer{
    static YLAudioPlayer *_sharedAudioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAudioPlayer = [[YLAudioPlayer alloc] init];
    });
    
    return _sharedAudioPlayer;
}

#pragma mark ===========  Interruption, Route changed  =========

- (void)interruption:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSUInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan && !DEFAULTS(bool, ForcePausePlayer)) {
        _interruptedWhilePlaying = YES;
        SET_DEFAULTS(Bool, ForcePausePlayer, YES);
        [self pause];
    } else if (interuptionType == AVAudioSessionInterruptionTypeEnded && _interruptedWhilePlaying) {
        _interruptedWhilePlaying = NO;
        SET_DEFAULTS(Bool, ForcePausePlayer, NO);
        [self play];
    }
    UALog(@"YLAudioPlayer interruption: %@", interuptionType == AVAudioSessionInterruptionTypeBegan ? @"began" : @"end");
}

- (void)routeChange:(NSNotification *)notification
{
    NSDictionary *routeChangeDict = notification.userInfo;
    NSUInteger routeChangeType = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && DEFAULTS(bool, ForcePausePlayer)) {
        _routeChangedWhilePlaying = YES;
        [self pause];
//        SET_DEFAULTS(Bool, ForcePausePlayer, YES);
    } else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable && _routeChangedWhilePlaying) {
        _routeChangedWhilePlaying = NO;
//        SET_DEFAULTS(Bool, ForcePausePlayer, NO);
        [self play];
    }
    UALog(@"YLAudioPlayer routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
}

#pragma mark - save and load
- (void)loadCode
{
    NSString *filePath = [[NSString documentDirectory] stringByAppendingPathComponent:YL_FILE_NAME];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *tracks = [unArchiver decodeObjectForKey:YL_PlaylistObject_Key];
    NSInteger index = [unArchiver decodeIntegerForKey:YL_PlaylistIndex_Key];
    if (tracks && [tracks count]>=index) {
        _currentTrack = index;
        _musics = tracks;
        _music = _musics[_currentTrack];
        [self checkMediaInfoAndConfigPlayer];
//        _firstLoad = NO;
    }else{
        _currentTrack = 0;
    }
    SET_DEFAULTS(Bool, YL_AUDIOPLAYER_ENTERBEGORAD, NO);
}

- (void)saveCode{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSString *filePath = [[NSString documentDirectory] stringByAppendingPathComponent:YL_FILE_NAME];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeInteger:_currentTrack forKey:YL_PlaylistIndex_Key];
    [archiver encodeObject:_musics forKey:YL_PlaylistObject_Key];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:filePath atomically:YES];
    if (success) {
        SET_DEFAULTS(Bool, YL_AUDIOPLAYER_ENTERBEGORAD, YES);
    }
}

#pragma mark - seek

- (void)audioPlayerDidSeekToPosition:(CGFloat)position{
    if (_music.source == MusicSourceSpotify) {
        UserAccount *userAccount =[PTUtilities readLoginUser];
        if (!userAccount.spotifyAccount || ![userAccount.spotifyAccount.product isEqualToString:@"premium"]) {
            [_streamPlayer seekToTime:position];
        }else{
            [_spotifyPlayer seekToOffset:position callback:nil];
        }
    }else if(_music.source == MusicSourceRdio){
        [_rdioPlayer.player seekToPosition:position];
    }else if(_music.source == MusicSourceSoundCloud){
        [_systemPlayer setCurrentTime:position];
    }else{
        [_streamPlayer seekToTime:position];
    }
}

#pragma mark - public method

- (void)reloadData{
    if (_musics) {
        [self destroyCurrentPlayer];
        _music = _musics[_currentTrack];
        
        if ([self.delegate respondsToSelector:@selector(audioPlayer:currentPlayMusic:)]) {
            [self.delegate audioPlayer:self currentPlayMusic:_music];
        }
        
        if ([self.delegate respondsToSelector:@selector(audioPlayer:listCount:currentIndex:)]) {
            [self.delegate audioPlayer:self listCount:[self musicListCount] currentIndex:_currentTrack+1];
        }
        
        if (![PTUtilities isNetWorkConnect]) {
            [self playbackStatePauseWithMsg:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
            return;
        }
        
        if (![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi] && !DEFAULTS(bool, NO_WIFI_PLAY_SETTING)) {
            if (!DEFAULTS(bool, NoWifiPlaySettingCancel)) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:PTNSLocalizedString(@"NotWifiPlayMusicMsgKey", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil)
                                                          otherButtonTitles:PTNSLocalizedString(@"OKButtonMsgKey",nil), nil];
                alertView.tag = 7000;
                [alertView show];
            }
            return;
        }
        
//        if (_music.source == MusicSourceSoundCloud) {
//            SCAccount *account = [SCSoundCloud account];
//            if ([PTUtilities readLoginUser].soundCloudAccount == nil || !account) {
//                [PTUtilities showAlertMessageWithTitle:PTNSLocalizedString(@"SoundCloudAuthorizationPromptTitleMsgKey", nil)
//                                               message:PTNSLocalizedString(@"SoundCloudAuthorizationPromptMsgKey", nil)
//                                         okButtonTitle:PTNSLocalizedString(@"OKButtonMsgKey", nil)];
//                [self playbackStatePaused];
////                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:PTNSLocalizedString(@"SoundCloudAuthorizationPromptTitleMsgKey", nil)
////                                                                    message:PTNSLocalizedString(@"SoundCloudAuthorizationPromptMsgKey", nil)
////                                                                   delegate:self
////                                                          cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil)
////                                                          otherButtonTitles:PTNSLocalizedString(@"Goto", nil), nil];
////                alertView.tag = 7001;
////                [alertView show];
//                return;
//            }
//        }
        
        [self checkMediaInfoAndConfigPlayer];
        [self play];
    }
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 7000) {
        if (buttonIndex == 0) {
//            SET_DEFAULTS(Bool, NoWifiPlaySettingCancel, YES);
            SET_DEFAULTS(Bool, NoWifiPlaySettingCancel, NO);
        }else{
            SET_DEFAULTS(Bool, NoWifiPlaySettingCancel, NO);
            SET_DEFAULTS(Bool, NO_WIFI_PLAY_SETTING, YES);
            [self configPlayInfo];
        }
    }
//    else if (alertView.tag == 7001){
//        if (buttonIndex == 1) {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//            ConnectServiceViewController *csvc = [storyboard instantiateViewControllerWithIdentifier:@"musicAuthorizationVC"];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:csvc];
//            csvc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelConnection:)];
//            [((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController presentViewController:nav animated:YES completion:nil];
//        }
//    }
}

//- (IBAction)cancelConnection:(id)sender{
//    [((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//}

- (void)reloadDataPlay{
    [self reloadData];
//    [self play];
}

- (void)addMusics:(NSArray *)musics{
    _musics = musics;
}

- (Music *)currentPlayMusic{
    return _music;
}

- (Music *)objectAtIndex:(NSInteger)index{
    return _musics[index];
}

- (NSInteger)musicListCount{
    return [_musics count];
}

- (void)play{
    if (self.isPlaying) {
        //暂停
        [self pause];
    }else{
        [self startPlaybackTimer];
        if (_music.source == MusicSourceSpotify) {
            UserAccount *userAccount =[PTUtilities readLoginUser];
            if (!userAccount.spotifyAccount || ![userAccount.spotifyAccount.product isEqualToString:@"premium"]) {
                [self playiTunes];
            }else{
                [self playSpotify];
            }
        }else if(_music.source == MusicSourceRdio){
            [self playRdio];
        }else if(_music.source == MusicSourceSoundCloud){
            [self playSoundCloud];
        }else{
            [self playiTunes];
        }
        
        [self playbackStateLoading];
    }
}

- (void)pause{
    [self stopPlaybackTimer];
    
    if (_music.source == MusicSourceSpotify) {
        UserAccount *userAccount =[PTUtilities readLoginUser];
        if (!userAccount.spotifyAccount || ![userAccount.spotifyAccount.product isEqualToString:@"premium"]) {
            [self pauseiTunes];
        }else{
            [self pauseSpotify];
        }
    }else if(_music.source == MusicSourceRdio){
        [self pauseRdio];
    }else if(_music.source == MusicSourceSoundCloud){
        [self pauseSoundCloud];
    }else{
        [self pauseiTunes];
    }
    
    [self playbackStatePaused];
}

- (void)next{
    switch (_repeatModel) {
        case MusicRepeatModelLoop:{
            // 单曲循环不+1
//            if ((++_currentTrack) >= [self musicListCount]) {
//                _currentTrack = 0;
//            }
            [self reloadDataPlay];
        }
            break;
        case MusicRepeatModelShuffle:{
            _currentTrack = arc4random() % [self musicListCount];
            if ([self musicListCount]==1) {
                _currentTrack=0;
                [self play];
            }else{
                if (_currentTrack == [self musicListCount]) {
                    _currentTrack = [self musicListCount]- 1;
                }
                [self reloadDataPlay];
            }
        }
            break;
        default:{
            if ((++_currentTrack) >= [self musicListCount]) {
                _currentTrack = 0;
                [self pause];
            }else{
                [self reloadDataPlay];
            }
        }
            break;
    }
//    [self play];
}

- (void)previous{
    switch (_repeatModel) {
        case MusicRepeatModelLoop:{
//            if ((--_currentTrack) < 0) {
//                _currentTrack = [self musicListCount]-1;
//            }
            
            [self reloadDataPlay];
        }
            break;
        case MusicRepeatModelShuffle:{
            _currentTrack = arc4random() % [self musicListCount];
            if ([self musicListCount]==1) {
                _currentTrack = 0;
                [self play];
            }else{
                if (_currentTrack == [self musicListCount]) {
                    _currentTrack = [self musicListCount]- 1;
                }
                [self reloadDataPlay];
            }
        }
            break;
        default:{
            if ((--_currentTrack) < 0) {
                _currentTrack = [self musicListCount]-1;
                [self pause];
            }else{
                [self reloadDataPlay];
            }
        }
            break;
    }
//    [self play];
}

-(void)stopPlay
{
//    _playing = NO;
//    _music = nil;
    [self destroyCurrentPlayer];
    postNotification(STOP_BALANCER_ANIMATION, self.currentPlayMusic, nil);
}

#pragma mark - destory player

- (void)destroyCurrentPlayer{
    [self playbackStatePaused];
//    _playing = NO;
    [self pause];
    _playbackState = MusicPlaybackStatePaused;
    [self stopPlaybackTimer];
    [self destroyStreamPlayer];
    [self stopSpotify];
    [self stopRdioPlayer];
    [self stopSoundCloud];
}

#pragma mark - Timer
- (void)startPlaybackTimer{
    if (_music.source == MusicSourceSpotify){
        UserAccount *userAccount =[PTUtilities readLoginUser];
        if (!userAccount.spotifyAccount || ![userAccount.spotifyAccount.product isEqualToString:@"premium"]) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(streamTimerAction:) userInfo:nil repeats:YES];
        }else{
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(spotifyTimerAction:) userInfo:nil repeats:YES];
        }
    }else if(_music.source == MusicSourceRdio){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(rdioTimerAction:) userInfo:nil repeats:YES];
    }else if (_music.source == MusicSourceSoundCloud){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(streamTimerAction:) userInfo:nil repeats:YES];//systemPlayerTimerAction
    }else if (_music.source == MusicSourceiTunes){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(streamTimerAction:) userInfo:nil repeats:YES];
    }
}

- (void)stopPlaybackTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - repeat mode,finished
- (void)currentTrackFinished{
    if ((self.musicListCount-1) == _currentTrack ) {
        // 播放列表里的最后的首歌
        postNotification(PlaylistLastMusicPlayed, _music, nil);
    }
//    _playing = NO;
    [self pause];
    _playbackState = MusicPlaybackStatePaused;
    postNotification(STOP_BALANCER_ANIMATION, self.currentPlayMusic, nil);
    if ([self.delegate respondsToSelector:@selector(audioPlayer:currentTrackFinished:)]) {
        [self.delegate audioPlayer:self currentTrackFinished:YES];
    }
    [self next];
}

#pragma mark - player
#pragma mark - spotify player

- (void)stopSpotify{
    if (_spotifyPlayer != nil) {
        [_lock lock];
        [_spotifyPlayer setIsPlaying:NO callback:nil];
        _spotifyPlayer.delegate = nil;
        _spotifyPlayer.playbackDelegate = nil;
        [_lock unlock];
    }
}

- (void)configSpotifyPlayer{
    UserAccount *userAccount =[PTUtilities readLoginUser];
    
    if (_spotifyPlayer == nil) {
        _spotifyPlayer = [SPTAudioStreamingController new];
        _spotifyPlayer.delegate = self;
        _spotifyPlayer.playbackDelegate = self;
    }else{
        _spotifyPlayer.delegate = self;
         _spotifyPlayer.playbackDelegate = self;
    }
    
    if ([userAccount.spotifyAccount.expiresDate compare:[NSDate date]]==NSOrderedAscending) {
        
        //刷新Token
        [AuthorizationViewController refreshSpotifyTokenWithRefreshToken:userAccount completion:^(UserAccount *user, NSError *error) {
            if (error) {
                _playbackState = MusicPlaybackStatePaused;
                if ([self.delegate respondsToSelector:@selector(audioPlayerError:message:)]) {
                    [self.delegate audioPlayerError:self message:PTNSLocalizedString(@"SpotifyRefreshTokenErrorMsgKey", nil)];
                }
            }else{
                [self playSpotifyTemp];
            }
        }];
    }else{
        [self playSpotifyTemp];
    }
}

- (void)pauseSpotify{
    [_spotifyPlayer setIsPlaying:NO callback:nil];
}

- (void)playSpotify{
    [_spotifyPlayer setIsPlaying:YES callback:nil];
}

- (void)playSpotifyTemp{
    UserAccount *userAccount =[PTUtilities readLoginUser];
    
    if (!userAccount.spotifyAccount || ![userAccount.spotifyAccount.product isEqualToString:@"premium"]) {
        [self playiTunes];
        return;
    }
    
    SPTSession *session = [[SPTSession alloc] initWithUserName:userAccount.spotifyAccount.userName
                                                   accessToken:userAccount.spotifyAccount.accessToken
                                                expirationDate:userAccount.spotifyAccount.expiresDate];

    [_spotifyPlayer loginWithSession:session callback:^(NSError *error) {
        [_spotifyPlayer setIsPlaying:NO callback:nil];
        [_spotifyPlayer playURI:_music.trackURL callback:nil];
        [self playbackStatePlaying];
    }];
}

#pragma mark - rdio player

- (void)configRdioPlayer{
    UserAccount *userAccount =[PTUtilities readLoginUser];
    
    if (!_rdioPlayer) {
        _rdioPlayer = [[Rdio alloc] initWithConsumerKey:userAccount.rdioAccount.rdioKey andSecret:userAccount.rdioAccount.rdioSecret delegate:self];
        [_rdioPlayer authorizeUsingAccessToken:userAccount.rdioAccount.fullAccessToken];
        [_rdioPlayer preparePlayerWithDelegate:self];
        [_rdioPlayer.player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kRdioDurationKVOKey];
    }
    
    [_rdioPlayer.player playSource:[_music.trackURL absoluteString]];
}

- (void)pauseRdio{
    [_rdioPlayer.player togglePause];
}

- (void)playRdio{
    [_rdioPlayer.player play];
}

- (void)stopRdioPlayer{
    if (_rdioPlayer != nil) {
        [_rdioPlayer.player stop];
        [_rdioPlayer.player removeObserver:self forKeyPath:@"duration" context:kRdioDurationKVOKey];
        _rdioPlayer.delegate = nil;
        _rdioPlayer.player.delegate = nil;
        _rdioPlayer = nil;
    }
}

#pragma mark - soundCloud player

- (void)configSoundCloudPlayer{
//    SCAccount *account = [SCSoundCloud account];
//    _hysteriaPlayerFirst = NO;
//    
//    if (_soundCloudRequest) {
//        [_soundCloudRequest cancel];
//        _soundCloudRequest = nil;
//    }
//    
////    [[HysteriaPlayer sharedInstance] removeAllItems];
//    
//    _soundCloudRequest = [SCRequest performMethod:SCRequestMethodGET
//                  onResource:_music.trackURL
//             usingParameters:nil
//                 withAccount:account
//      sendingProgressHandler:nil
//             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                 UALog(@"soundCloud..mp3url...%@",response.URL);
//                 if(error){
//                     if (_streamPlayer) {
//                         [_streamPlayer removeAllItems];
//                     }
//                     [self playbackStatePauseWithMsg:[error localizedDescription]];
//                 }else{
//                     if (_streamPlayer == nil) {
//                         _streamPlayer = [HysteriaPlayer sharedInstance];
//                         [_streamPlayer addDelegate:self];
//                     }
//                     _hysteriaPlayerFirst = NO;
//                     [_streamPlayer removeAllItems];
//                     
//                     [_streamPlayer setupSourceGetter:^NSURL *(NSUInteger index) {
//                         return response.URL;
//                     } ItemsCount:1];
//                     if (_firstLoad) {
//                         [self playSoundCloud];
//                     }
////                     NSError *playerError;
////                     _systemPlayer = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
//////                     [_systemPlayer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kSystemPlayerDurationKVOKey];
////                     UALog(@"systemPlayer..Error...%@",playerError);
////                     [_systemPlayer prepareToPlay];
////                     [_systemPlayer play];
//                 }
//             }];
    
    if (_streamPlayer == nil) {
        _streamPlayer = [HysteriaPlayer sharedInstance];
        [_streamPlayer addDelegate:self];
    }
    _hysteriaPlayerFirst = NO;
    [_streamPlayer removeAllItems];
    
    [_streamPlayer setupSourceGetter:^NSURL *(NSUInteger index) {
        return [_music soundCloudURL];
    } ItemsCount:1];
}

- (void)pauseSoundCloud{
    if (_streamPlayer) {
        [_streamPlayer pausePlayerForcibly:YES];
        [_streamPlayer pause];
    }
}

- (void)playSoundCloud{
    if (_streamPlayer) {
        if (!_hysteriaPlayerFirst) {
            _hysteriaPlayerFirst = YES;
            [_streamPlayer pausePlayerForcibly:NO];
            [_streamPlayer performSelector:@selector(fetchAndPlayPlayerItem:) withObject:0 afterDelay:1.0];
        }else{
            [_streamPlayer pausePlayerForcibly:NO];
            [_streamPlayer play];
            [self playbackStatePlaying];
        }
    }
}

- (void)stopSoundCloud{
    if (_streamPlayer != nil) {
        [_streamPlayer pausePlayerForcibly:YES];
        [_streamPlayer pause];
        [_streamPlayer removeAllItems];
    }
    if (_soundCloudRequest != nil) {
        [_soundCloudRequest cancel];
        _soundCloudRequest = nil;
    }
}

#pragma mark - DOUAudio Streamer
#pragma mark - iTunes player

- (void)pauseiTunes{
    [_streamPlayer pausePlayerForcibly:YES];
    [_streamPlayer pause];
}

- (void)playiTunes{
    if (!_hysteriaPlayerFirst) {
        _hysteriaPlayerFirst = YES;
        [_streamPlayer performSelector:@selector(fetchAndPlayPlayerItem:) withObject:0 afterDelay:1.0];
        [_streamPlayer pausePlayerForcibly:NO];
    }else{
        [_streamPlayer pausePlayerForcibly:NO];
        [_streamPlayer play];
        [self playbackStatePlaying];
    }
}

- (void)destroyStreamPlayer
{
    if (_streamPlayer != nil) {
        [_streamPlayer pausePlayerForcibly:YES];
        [_streamPlayer pause];
        [_streamPlayer removeAllItems];
    }
}

- (void)configStreamPlayer
{
    if (_streamPlayer == nil) {
        _streamPlayer = [HysteriaPlayer sharedInstance];
        [_streamPlayer addDelegate:self];
    }
    _hysteriaPlayerFirst = NO;
    [_streamPlayer removeAllItems];
    [_streamPlayer setupSourceGetter:^NSURL *(NSUInteger index) {
        return _music.trackURL;
    } ItemsCount:1];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kDouAudioStreamerStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDouAudioStreamerDurationKVOKey) {
        [self performSelector:@selector(streamTimerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }else if(context == kRdioDurationKVOKey){
        [self performSelector:@selector(rdioTimerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }else if(context == kSystemPlayerDurationKVOKey){
        [self performSelector:@selector(systemPlayerTimerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)streamTimerAction:(id)timer
{
    float currentTime = 0.0f;
    if ([_streamPlayer getPlayingItemDurationTime] == 0.0f) {
        currentTime = 0.0f;
        UALog(@"currentTime..%f",currentTime);
        return;
    }else{
        currentTime = [_streamPlayer getPlayingItemCurrentTime];
    }
    
    UALog(@"currentTime..%f",currentTime);
    if ([self.delegate respondsToSelector:@selector(audioPlayer:durationUpdate:currentTimeUpdate:)]) {
        [self.delegate audioPlayer:self durationUpdate:[_streamPlayer getPlayingItemDurationTime] currentTimeUpdate:currentTime];
    }
    

//    UALog(@"current...%f..%f...%d",floorf([_streamPlayer getPlayingItemCurrentTime]),floorf([_streamPlayer getPlayingItemDurationTime]),floorf([_streamPlayer getPlayingItemCurrentTime])>=floorf([_streamPlayer getPlayingItemDurationTime]));
    if (floorf([_streamPlayer getPlayingItemCurrentTime])>=floorf([_streamPlayer getPlayingItemDurationTime]) && [_streamPlayer getPlayingItemDurationTime]>0) {
        if ([self.delegate respondsToSelector:@selector(audioPlayer:durationUpdate:currentTimeUpdate:)]) {
            [self.delegate audioPlayer:self durationUpdate:[_streamPlayer getPlayingItemDurationTime] currentTimeUpdate:0];
        }
    }
}

- (void)spotifyTimerAction:(id)timer{
    
    float duration = [[_spotifyPlayer.currentTrackMetadata objectForKey:SPTAudioStreamingMetadataTrackDuration] floatValue];
    if ((int)_spotifyPlayer.currentPlaybackPosition == 0 || (int)duration==0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(audioPlayer:durationUpdate:currentTimeUpdate:)]) {
        [self.delegate audioPlayer:self durationUpdate:duration currentTimeUpdate:_spotifyPlayer.currentPlaybackPosition];
    }
    
    if (floorf(_spotifyPlayer.currentPlaybackPosition)>=floorf(duration) && duration>0) {
        [self currentTrackFinished];
    }
}

- (void)rdioTimerAction:(id)timer{

    if (!_rdioPlayer || _rdioPlayer.player.duration == 0 || _rdioPlayer.player.position == 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(audioPlayer:durationUpdate:currentTimeUpdate:)]) {
        [self.delegate audioPlayer:self durationUpdate:_rdioPlayer.player.duration currentTimeUpdate:_rdioPlayer.player.position];
    }
    
    if (floorf(_rdioPlayer.player.position)>=floorf(_rdioPlayer.player.duration) && _rdioPlayer.player.duration>0) {
        [self currentTrackFinished];
    }
}

- (void)systemPlayerTimerAction:(id)timer{
    if (!_systemPlayer || _systemPlayer.duration == 0 || _systemPlayer.currentTime == 0) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(audioPlayer:durationUpdate:currentTimeUpdate:)]) {
        [self.delegate audioPlayer:self durationUpdate:_systemPlayer.duration currentTimeUpdate:_systemPlayer.currentTime];
    }
    if (floorf(_systemPlayer.currentTime)>=floorf(_systemPlayer.duration) && _systemPlayer.duration>0) {
        _systemPlayer.currentTime = 0;
        if ([self.delegate respondsToSelector:@selector(audioPlayer:durationUpdate:currentTimeUpdate:)]) {
            [self.delegate audioPlayer:self durationUpdate:_systemPlayer.duration currentTimeUpdate:0];
        }
        [self currentTrackFinished];
    }
}

- (void)_updateStatus
{
    switch ([_streamPlayer getHysteriaPlayerStatus]) {
        case HysteriaPlayerStatusPlaying:
            [self playbackStatePlaying];
            break;
        case HysteriaPlayerStatusBuffering:
            [self playbackStateLoading];
            break;
        case HysteriaPlayerStatusUnknown:
            [self playbackStatePauseWithMsg:PTNSLocalizedString(@"MusicPlayStreamErrorMsgKey", nil)];
            break;
        default:
            break;
    }
}

#pragma mark - HysteriaPlayerDelegate

- (void)hysteriaPlayerCurrentItemChanged:(AVPlayerItem *)item {
    UALog(@"item...%@",item);
}
- (void)hysteriaPlayerRateChanged:(BOOL)isPlaying {
    if (isPlaying) {
        [self playbackStatePlaying];
    }
}
- (void)hysteriaPlayerDidReachEnd {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self currentTrackFinished];
            if ([self.delegate respondsToSelector:@selector(audioPlayer:durationUpdate:currentTimeUpdate:)]) {
                [self.delegate audioPlayer:self durationUpdate:[_streamPlayer getPlayingItemDurationTime] currentTimeUpdate:0];
            }
        });
    });
}
- (void)hysteriaPlayerCurrentItemPreloaded:(CMTime)time {
    UALog(@"CMTime....%f",CMTimeGetSeconds(time));
}

#pragma mark - Spotify Delegate

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:PTNSLocalizedString(@"SpotifySystemMsgKey", nil)
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:PTNSLocalizedString(@"OKButtonMsgKey", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying{
    if (isPlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playbackStatePlaying];
        });
    }
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri{
    UALog(@"spotify trackURi..%@",trackUri);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playbackStatePauseWithMsg:PTNSLocalizedString(@"SpotifyPlayTrackFailedMsgKey", nil)];
    });
}

-(void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playbackStatePauseWithMsg:PTNSLocalizedString(@"SpotifyAuthorizationFailedMsgKey", nil)];
    });
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset{
    UALog(@"spotify...offset...%lf",offset);
}

#pragma mark - YLAudioPlayer control
- (void)playCurrentTrack:(Music *)music{
    _errorCount = 0;
    _musics = @[music];
    _currentTrack = 0;
    [self reloadDataPlay];
}

- (void)playTracks:(NSArray *)musics startIndex:(NSInteger)currentInext{
    _musics = musics;
    _currentTrack = currentInext;
    _errorCount = 0;
    [self reloadDataPlay];
}

- (void)increasePlaylistCount {
    if ([YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId) {
        UserAccount *user = [PTUtilities readLoginUser];
        [[PTAppClientEngine sharedClient] increasePlaylistPlayingCountWithUserId:user.userId token:user.userToken playlistId:[YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId songId:[YLAudioPlayer sharedAudioPlayer].currentMusicID completionBlock:^(BOOL success, NSError *error) {
            if (success) {
                UALog(@"increase playlist playing count success");
            } else {
                UALog(@"increase playlist playing count failed");
            }
        }];
    }
}

- (void)configNowPlayingInfoCenter{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:_music.trackName ?:@"" forKey:MPMediaItemPropertyTitle];
            [dict setObject:_music.trackTime ?:[NSNumber numberWithInt:0] forKey:MPMediaItemPropertyPlaybackDuration];
            [dict setObject:[NSNumber numberWithFloat:0] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [dict setObject:[NSNumber numberWithInt:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
            
            UIImage *image = [UIImage imageNamed:@"CD-Cover"];
            
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
            [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
            
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        
            UALog(@"_music.artworkUrlBigger...%@",_music.artworkUrlBigger);
            [_loadCoverImageView sd_setImageWithURL:_music.artworkUrlBigger completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[image imageToScaleSize:CGSizeMake(320.0, 320.0) withSizeType:ImageResizingCropCenter]];
                    [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
                    
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
                }
            }];
        });
    }
    
    //post 播放记录
    if (_music.sid != nil && [PTUtilities isNetWorkConnect]) {
        UserAccount *ua = [PTUtilities readLoginUser];
        [[PTAppClientEngine sharedClient] addUserRecentPlayWithUserId:ua.userId
                                                                token:ua.userToken
                                                              musicId:_music.sid
                                                            musicName:_music.trackName];
        [self increasePlaylistCount];
        
    }
}

- (void)checkMediaInfoAndConfigPlayer{
//    [self destroyCurrentPlayer];
//add 2014.12.19
//    if (_music.source == MusicSourceSoundCloud) {
//        SCAccount *account = [SCSoundCloud account];
//        if ([PTUtilities readLoginUser].soundCloudAccount == nil || !account) {
//            [self playbackStatePaused];
//            return;
//        }
//    }
    
    [self configPlayInfo];
    
}

- (void)configPlayInfo{
    [self configNowPlayingInfoCenter];
    
    if (_music.source == MusicSourceSpotify) {
        UserAccount *userAccount =[PTUtilities readLoginUser];
        if (!userAccount.spotifyAccount || ![userAccount.spotifyAccount.product isEqualToString:@"premium"]) {
            if (!userAccount.spotifyAccount) {
                if ([self.delegate respondsToSelector:@selector(audioPlayerError:message:)]) {
                    [self.delegate audioPlayerError:self message:PTNSLocalizedString(@"SpotifyAuthorizationErrorMsgKey", nil)];
                }
            }
            
            if (![userAccount.spotifyAccount.product isEqualToString:@"premium"]) {
                if ([self.delegate respondsToSelector:@selector(audioPlayerError:message:)]) {
                    [self.delegate audioPlayerError:self message:PTNSLocalizedString(@"NotSpotifyPremiumUserMsgKey", nil)];
                }
            }
            [self configStreamPlayer];
        }else{
            [self configSpotifyPlayer];
        }
    }else if(_music.source == MusicSourceRdio){
        [self configRdioPlayer];
    }else if(_music.source == MusicSourceSoundCloud){
        [self configSoundCloudPlayer];
    }else if(_music.source == MusicSourceiTunes){
        [self configStreamPlayer];
    }else{
        
        _errorCount++;
        if (_errorCount==self.musicListCount) {
            [self playbackStatePaused];
        }else{
            [self next];
        }
    }
}

#pragma mark - Rdio delegate

-(BOOL)rdioIsPlayingElsewhere{
    return NO;
}

/**
 * Notification that the player has changed states. See <code>RDPlayerState</code>.
 */
-(void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState{
    UALog(@"RDPlayerState-old...%d,,,,,-new..%d",oldState,newState);
//    _playing = (newState != RDPlayerStateInitializing && newState != RDPlayerStateStopped);
    if ((newState != RDPlayerStateInitializing && newState != RDPlayerStateStopped)) {
        [self playbackStatePlaying];
    }else if (newState == RDPlayerStatePaused){
        [self playbackStatePaused];
    }
    
}

- (BOOL)rdioPlayerFailedDuringTrack:(NSString *)trackKey withError:(NSError *)error
{
    UALog(@"Rdio failed to play track %@\n%@", trackKey, error);
    if (error) {
        [self playbackStatePauseWithMsg:PTNSLocalizedString(@"RdioPlayTrackFailedMsgKey", nil)];
    }
    return NO;
}

- (void)rdioAuthorizationFailed:(NSError *)error{
    UALog(@"Rdio authorization failed \n%@", error);
    if (error) {
        [self playbackStatePauseWithMsg:PTNSLocalizedString(@"RdioAuthorizationFailedMsgKey", nil)];
    }
}

-(BOOL)isPlaying
{
    BOOL isPlaying = NO;
    switch (self.playbackState) {
        case MusicPlaybackStateLoading:
            isPlaying = YES;
            break;
        case MusicPlaybackStatePlaying:
            isPlaying = YES;
            break;
        default:
            isPlaying = NO;
            break;
    }
    return isPlaying;
}

#pragma mark - MusicPlaybackState Method

-(NSString *)currentMusicID
{
//    if (self.currentPlayMusic.trackId && self.currentPlayMusic.source > 0) {
//        return [NSString stringWithFormat:@"%@",self.currentPlayMusic.sid];
//    }
//    else
        return [NSString stringWithFormat:@"%@",self.currentPlayMusic.sid];
}

- (void)playbackStatePlaying{
//    _playing = YES;
    _playbackState = MusicPlaybackStatePlaying;
    if ([self.delegate respondsToSelector:@selector(audioPlayerStartPlaying:)]) {
        [self.delegate audioPlayerStartPlaying:self];
    }
    postNotification(START_BALANCER_ANIMATION, self.currentPlayMusic, nil);
}

- (void)playbackStateLoading{
    _playbackState = MusicPlaybackStateLoading;
    if ([self.delegate respondsToSelector:@selector(audioPlayerStartLoading:)]) {
        [self.delegate audioPlayerStartLoading:self];
    }
      postNotification(START_BALANCER_ANIMATION,self.currentPlayMusic, nil);
}

- (void)playbackStatePaused{
    _playbackState = MusicPlaybackStatePaused;
    if ([self.delegate respondsToSelector:@selector(audioPlayerStartPause:)]) {
        [self.delegate audioPlayerStartPause:self];
    }
    postNotification(STOP_BALANCER_ANIMATION, self.currentPlayMusic, nil);
}

- (void)playbackStatePauseWithMsg:(NSString *)msg{
    _playbackState = MusicPlaybackStatePaused;
    [self delegateErrorWithMsg:msg];
    postNotification(STOP_BALANCER_ANIMATION, self.currentPlayMusic, nil);
}

- (void)delegateErrorWithMsg:(NSString *)msg{
    if ([self.delegate respondsToSelector:@selector(audioPlayerError:message:)]) {
        [self.delegate audioPlayerError:self message:msg];
    }
}

@end
