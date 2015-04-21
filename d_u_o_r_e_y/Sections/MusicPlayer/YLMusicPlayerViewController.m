//
//  MusicPlayerViewController.m
//  Duorey
//
//  Created by xdy on 14/11/12.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "YLMusicPlayerViewController.h"
#import "YLAudioPlayer.h"
#import "Music.h"
#import "CBAutoScrollLabel.h"
#import "NSDateFormatter+Duration.h"
#import <UALogger.h>
#import "PlaylistCell.h"
#import "NSString+Path.h"
#import "NSString+Additions.h"
#import "NSString+Hash.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Compress.h"
#import "PTUtilities.h"
#import "PTTheme.h"
#import "AddMusicToPlaylistViewController.h"
#import "PTAppClientEngine.h"

@interface YLMusicPlayerViewController ()<YLAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
,UIAlertViewDelegate
#endif
>


//title
@property (weak, nonatomic) IBOutlet UIView *musicTitleView;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *artistNameLabel;


//时间控制
@property (weak, nonatomic) IBOutlet UILabel *listCountLabel;//列表内容指示
@property (weak, nonatomic) IBOutlet UISlider *timeLengthSlider;//歌曲时间长度
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;//已经播放的时间
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;//剩余时间
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;//播放模式
@property (weak, nonatomic) IBOutlet UIButton *addToPlaylistButton;//讲歌曲添加到歌单

//cover
@property (weak, nonatomic) IBOutlet UIImageView *musicCoverImageView;

//播放控制
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet MPVolumeView *volumeView;
@property (strong, nonatomic) UISlider *mpVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIView *bottomVolumeView;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *purchaseView;

//playlist
@property (nonatomic) BOOL effectToggle;
@property (strong, nonatomic) IBOutlet UITableView *playlistTableView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicatorView;
@property (assign, nonatomic) BOOL didPostPlayingNotification;
@property (assign, nonatomic) BOOL didPostPauseNotification;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *blackMaskView;
@end

@implementation YLMusicPlayerViewController



- (void)alertViewForAuthNeedForMusicSource:(MusicSource)source {
    if ([YLAudioPlayer sharedAudioPlayer].currentPlayMusic.source == source) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:PTNSLocalizedString(@"SoundCloudAuthorizationPromptTitleMsgKey", nil)
                                                                                 message:PTNSLocalizedString(@"SoundCloudAuthorizationPromptMsgKey", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:PTNSLocalizedString(@"OKButtonMsgKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
#else
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:PTNSLocalizedString(@"SoundCloudAuthorizationPromptTitleMsgKey", nil)
                                                            message:PTNSLocalizedString(@"SoundCloudAuthorizationPromptMsgKey", nil)
                                                           delegate:self
                                                  cancelButtonTitle:PTNSLocalizedString(@"OKButtonMsgKey", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
#endif
    }
}

- (void)setPlayButtonEnable:(BOOL)enable
{
    self.playButton.enabled = enable;
    self.previousButton.enabled = enable;
    self.nextButton.enabled = enable;
    self.repeatButton.enabled = enable;
    self.addToPlaylistButton.enabled = enable;
    if ([YLAudioPlayer sharedAudioPlayer].musicListCount) {
        [self updateNextAndPreviousButtonState];
    }
}

- (void)updateMusicUI:(Music *)music{
//    if (self.loadingActivityIndicatorView.isAnimating && ([YLAudioPlayer sharedAudioPlayer].playbackState != MusicPlaybackStateLoading)) {
//        [self.loadingActivityIndicatorView stopAnimating];
//    }
    
    self.listCountLabel.text = [NSString stringWithFormat:PTNSLocalizedString(@"MusicPlaylistCountMsgKey", nil),[[YLAudioPlayer sharedAudioPlayer] musicListCount] > 0 ? [YLAudioPlayer sharedAudioPlayer].currentTrack+1 : 0,[[YLAudioPlayer sharedAudioPlayer] musicListCount]];
    
    self.musicTitleLabel.text = music.trackName;
    self.artistNameLabel.text = music.artistName;
    
    NSString *elapsed = [NSDateFormatter formattedDuration:0.0f];

    long trackTimeLong;
    if ([[music trackTime] isKindOfClass:[NSString class]]) {
        NSString *trackTimeString = (NSString *)music.trackTime;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *trackTime = [numberFormatter numberFromString:trackTimeString];
        trackTimeLong = [trackTime longValue];
    }else{
        trackTimeLong = [music.trackTime longValue];
    }

    NSString *remaining = [NSDateFormatter formattedDuration:trackTimeLong];
    self.elapsedTimeLabel.text = elapsed;
    self.remainingTimeLabel.text = remaining;
    self.timeLengthSlider.maximumValue = [music.trackTime floatValue];
    self.timeLengthSlider.minimumValue = 0;
    self.timeLengthSlider.value = 0;
    
    UIImage *coverImage=nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachedImagePath = [[NSString imageDirectory] stringByAppendingPathComponent:[[music.artworkUrlBigger absoluteString] md5]];
    if (music.artworkUrlBigger == nil || ![fm fileExistsAtPath:cachedImagePath]) {
        coverImage = [UIImage imageNamed:@"CD-Cover"];
    }else{
        coverImage = [UIImage imageWithContentsOfFile:cachedImagePath];
    }
    
    UIImage *blurImage = [coverImage applyBlurWithRadius:5.0 tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];

    self.backgroundImageView.image = blurImage;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    __weak typeof(self) weakSelf = self;
    [self.musicCoverImageView sd_setImageWithURL:music.artworkUrlBigger placeholderImage:[UIImage imageNamed:@"CD-Cover"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            __strong typeof(self) strongSelf = weakSelf;
            [[image imageJPEGRepresentationWithCompressionQuality:1.0] writeToFile:cachedImagePath atomically:YES];
            strongSelf.musicCoverImageView.image = image;
            strongSelf.view.backgroundColor = [UIColor clearColor];
            UIImage *bImage = [image applyBlurWithRadius:5.0 tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
            strongSelf.backgroundImageView.image = bImage;
        }
    }];
    
    if ([YLAudioPlayer sharedAudioPlayer].playing) {
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
    }else{
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
    }

    //add 无数据判断
    if (![PTUtilities isNetWorkConnect] || [[YLAudioPlayer sharedAudioPlayer] musicListCount] <=0) {
        [self setPlayButtonEnable:NO];
        self.timeLengthSlider.enabled = NO;
    }else{
        [self setPlayButtonEnable:YES];
        self.timeLengthSlider.enabled = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showOrHidePurchaseView];
    UALog(@"current play list id: %@", [YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addActionToPurchaseAndShareViews];
    
    [self setBackButtonItemTitleByEmpty];
    [YLAudioPlayer sharedAudioPlayer].delegate = self;
    [self.volumeView sizeToFit];
    for (UIControl *view in self.volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            self.mpVolumeSlider = (UISlider *)view;
            [self.mpVolumeSlider addTarget:self action:@selector(mpVolumeValueChange:) forControlEvents:UIControlEventValueChanged];
            self.mpVolumeSlider.hidden = YES;
        }
    }

    [self.volumeSlider addTarget:self action:@selector(volumeValueChange:) forControlEvents:UIControlEventValueChanged];
    self.volumeSlider.minimumValue = 0.0f;
    self.volumeSlider.maximumValue = 1.0f;
    self.volumeSlider.value = self.mpVolumeSlider.value;
    [self.bottomVolumeView addSubview:self.volumeSlider];
    
    UALog(@"%@", [[YLAudioPlayer sharedAudioPlayer].currentPlayMusic.trackURL absoluteString]);
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"in" label:@"PL_in" value:nil];

    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.backgroundImageView atIndex:0];

    self.blackMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.blackMaskView.backgroundColor = [UIColor blackColor];
    self.blackMaskView.alpha = 0.2;
    [self.view insertSubview:self.blackMaskView aboveSubview:self.backgroundImageView];
    
    self.didPostPauseNotification = NO;
    self.didPostPlayingNotification = NO;
    
    self.loadingActivityIndicatorView.tintColor = [[PTThemeManager sharedTheme] navBarTintColor];
    [self.loadingActivityIndicatorView startAnimating];
    [self setPlayButtonEnable:NO];
    
//    id<PTTheme> theme = [PTThemeManager sharedTheme];
    
    self.effectToggle = NO;
    [self.artistNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    [self.artistNameLabel setTextColor:[UIColor colorWithWhite:0.224 alpha:1.000]];
    [self.musicTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f]];
    [self.musicTitleLabel setTextColor:[UIColor colorWithWhite:0.224 alpha:1.000]];
    NSInteger repeat = DEFAULTS(integer, MusicRepeatKey);
    if (repeat == MusicRepeatModelDefault) {
        [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"musicDefault"] forState:UIControlStateNormal];
    }else if (repeat == MusicRepeatModelLoop){
        [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"musicLoop"] forState:UIControlStateNormal];
    }else{
        [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"musicShuffle"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - volume slider value change

- (void)mpVolumeValueChange:(UISlider *)slider{
    self.volumeSlider.value = slider.value;
}

- (void)volumeValueChange:(UISlider *)slider{
    self.mpVolumeSlider.value = slider.value;
}

- (BOOL)onlyOneMusicInPlaylist {
    return [YLAudioPlayer sharedAudioPlayer].musicListCount == 1 ? YES : NO;
}

- (void)updateNextAndPreviousButtonState {
    
    NSInteger repeat = DEFAULTS(integer, MusicRepeatKey);
    if ((repeat == MusicRepeatModelDefault) && ([YLAudioPlayer sharedAudioPlayer].currentTrack == ([YLAudioPlayer sharedAudioPlayer].musicListCount - 1))) {
        self.previousButton.enabled = NO;
        self.nextButton.enabled = NO;
    }else{
        self.nextButton.enabled = [self onlyOneMusicInPlaylist] ? NO : YES;
        self.previousButton.enabled = [self onlyOneMusicInPlaylist] ? NO : YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateMusicUI:[YLAudioPlayer sharedAudioPlayer].currentPlayMusic];
}

#pragma mark - action

- (void)shareAction:(UITapGestureRecognizer *)sender {
    UALog(@"share action");
    [PTUtilities shareSongOrListWithID:nil songID:[YLAudioPlayer sharedAudioPlayer].currentMusicID controller:self];
}

- (void)purchaseAction:(UITapGestureRecognizer *)sender {
    NSString *buyURL = [YLAudioPlayer sharedAudioPlayer].currentPlayMusic.purchaseUrl;
    NSURL *purchaseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&at=11l32tc&ct=duorey",buyURL]];
    [[UIApplication sharedApplication] openURL:purchaseUrl];
}

- (IBAction)addCurrentPlayingMusicToPlaylistAction:(id)sender {
    if ([YLAudioPlayer sharedAudioPlayer].currentPlayMusic != nil) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"Click_p" label:@"add_p" value:nil];
        AddMusicToPlaylistViewController *addMusicToPlaylist = [self.storyboard instantiateViewControllerWithIdentifier:@"addMusicToPlaylistVC"];
        addMusicToPlaylist.playlistObjDic=(NSMutableDictionary *)[MTLJSONAdapter JSONDictionaryFromModel:[YLAudioPlayer sharedAudioPlayer].currentPlayMusic];
        [self.navigationController pushViewController:addMusicToPlaylist animated:YES];
    }
}

- (IBAction)timeSeekStarted:(UISlider *)sender {
    UALog(@"time seek start ");
    [[YLAudioPlayer sharedAudioPlayer] pause];
}

- (IBAction)timeSliderAction:(UISlider *)sender {
    NSString *elapsed = [NSDateFormatter formattedDuration:sender.value];
    NSString *remaining = [NSDateFormatter formattedDuration:(sender.maximumValue - sender.value)];
    self.elapsedTimeLabel.text = elapsed;
    self.remainingTimeLabel.text = remaining;
}

- (IBAction)timeSeekEnded:(UISlider *)sender {
    UALog(@"time seek end ");
    [[YLAudioPlayer sharedAudioPlayer] audioPlayerDidSeekToPosition:sender.value];
    [[YLAudioPlayer sharedAudioPlayer] play];
}

- (IBAction)playButtonAction:(UIButton *)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"Click_p" label:@"played" value:nil];
    switch ([YLAudioPlayer sharedAudioPlayer].playbackState) {
        case MusicPlaybackStateLoading:
        case MusicPlaybackStatePlaying:
        case MusicPlaybackStateError:
        {
//                SET_DEFAULTS(Bool, ForcePausePlayer, YES);
                [[YLAudioPlayer sharedAudioPlayer] pause];
        }
            break;
        default:
        {
//            SET_DEFAULTS(Bool, ForcePausePlayer, NO);
            [[YLAudioPlayer sharedAudioPlayer] play];
        }
            break;
    }
}


- (IBAction)previousAction:(UIButton *)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"Click_p" label:@"back" value:nil];
    [[YLAudioPlayer sharedAudioPlayer] previous];
    [self showOrHidePurchaseView];
}

- (IBAction)nextAction:(UIButton *)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"Click_p" label:@"next" value:nil];
    [[YLAudioPlayer sharedAudioPlayer] next];
    [self showOrHidePurchaseView];
}

- (IBAction)repeatModelAction:(UIButton *)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"Click_p" label:@"mode" value:nil];
    
    NSInteger repeat = DEFAULTS(integer, MusicRepeatKey);
    if (repeat == MusicRepeatModelDefault) {
        [YLAudioPlayer sharedAudioPlayer].repeatModel = MusicRepeatModelLoop;
        SET_DEFAULTS(Integer, MusicRepeatKey, MusicRepeatModelLoop);
        [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"musicLoop"] forState:UIControlStateNormal];
    }else if (repeat == MusicRepeatModelLoop){
        [YLAudioPlayer sharedAudioPlayer].repeatModel = MusicRepeatModelShuffle;
        SET_DEFAULTS(Integer, MusicRepeatKey, MusicRepeatModelShuffle);
        [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"musicShuffle"] forState:UIControlStateNormal];
    }else{
        [YLAudioPlayer sharedAudioPlayer].repeatModel = MusicRepeatModelDefault;
        SET_DEFAULTS(Integer, MusicRepeatKey, MusicRepeatModelDefault);
        [self.repeatButton setBackgroundImage:[UIImage imageNamed:@"musicDefault"] forState:UIControlStateNormal];
    }
}


- (IBAction)showPlaylistAction:(UIBarButtonItem *)sender {
    if (self.effectToggle) {
        [self animateTableViewToOffScreen];
    }else{
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"Click_p" label:@"play_list" value:nil];
        [self animateTableViewToScreen];
    }
}

- (IBAction)dismissPlayerAction:(UIBarButtonItem *)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"PL" action:@"out" label:@"PL_out" value:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            break;
        default:
            break;
    }
}
#endif

#pragma mark - YLAudioPlayerDelegate

- (void)audioPlayer:(YLAudioPlayer *)audioPlayer currentPlayMusic:(Music *)currentMusic{
    [self updateMusicUI:currentMusic];
    [self.playlistTableView reloadData];
}

- (void)audioPlayer:(YLAudioPlayer *)audioPlayer durationUpdate:(CGFloat)duration currentTimeUpdate:(CGFloat)currentTime{
    if (self.timeLengthSlider.value!=currentTime) {
        [self.loadingActivityIndicatorView stopAnimating];
    }
    NSString *elapsed = [NSDateFormatter formattedDuration:currentTime];
    NSString *remaining = [NSDateFormatter formattedDuration:(duration - currentTime)];
    self.timeLengthSlider.maximumValue = duration;
    self.timeLengthSlider.value = currentTime;
    self.remainingTimeLabel.text = remaining;
    self.elapsedTimeLabel.text = elapsed;
}

- (void)audioPlayer:(YLAudioPlayer *)audioPlayer listCount:(NSInteger)count currentIndex:(NSInteger)index{
    self.listCountLabel.text = [NSString stringWithFormat:PTNSLocalizedString(@"MusicPlaylistCountMsgKey", nil),index,count];
    NSInteger repeat = DEFAULTS(integer, MusicRepeatKey);
    if ((repeat == MusicRepeatModelDefault) && (count == index)) {
        self.previousButton.enabled = NO;
        self.nextButton.enabled = NO;
    }else{
        self.previousButton.enabled = YES;
        self.nextButton.enabled = YES;
    }
}

- (void)audioPlayerStartLoading:(YLAudioPlayer *)audioPlayer{
    UALog(@"audioLoading...");
    if (!self.loadingActivityIndicatorView.isAnimating && !audioPlayer.isPlaying) {
        [self.loadingActivityIndicatorView startAnimating];
    }
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
}
- (void)audioPlayerStartPlaying:(YLAudioPlayer *)audioPlayer{
    UALog(@"audioPlaying...");
    if ([self.loadingActivityIndicatorView isAnimating] && audioPlayer.isPlaying) {
        [self.loadingActivityIndicatorView stopAnimating];
        [self setPlayButtonEnable:YES];
    }
    if (!self.didPostPlayingNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPlayerStartPlayingNotification" object:nil];
        self.didPostPlayingNotification = YES;
    }
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
}

- (void)audioPlayerStartPause:(YLAudioPlayer *)audioPlayer{
    UALog(@"audioPausing...");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPlayerPauseNotification" object:nil];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
    if ([self.loadingActivityIndicatorView isAnimating]) {
        [self.loadingActivityIndicatorView stopAnimating];
    }
}

- (void)audioPlayerError:(YLAudioPlayer *)audioPlayer message:(NSString *)msg{
    UALog(@"audioError...%@",msg);
    if ([self.loadingActivityIndicatorView isAnimating] && !audioPlayer.isPlaying) {
        [self.loadingActivityIndicatorView stopAnimating];
    }
    [self setPlayButtonEnable:YES];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
}

- (void)audioPlayer:(YLAudioPlayer *)audioPlayer currentTrackFinished:(BOOL)finished {
    UALog(@"current track finished...");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPlayerCurrentTrackFinishedNotification" object:nil];
    [self.playlistTableView reloadData];
}

#pragma mark - play list

- (void)animateTableViewToScreen{
    self.effectToggle = YES;
    [UIView animateWithDuration:0.25 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.view addSubview:self.playlistTableView];
        self.playlistTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.playlistTableView reloadData];
    } completion:nil];
    
}

- (void)animateTableViewToOffScreen{
    self.effectToggle = NO;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.playlistTableView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        [self.playlistTableView removeFromSuperview];
    } completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[YLAudioPlayer sharedAudioPlayer] musicListCount];
}

- (void)configureCell:(PlaylistCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Music *mu = [[YLAudioPlayer sharedAudioPlayer] objectAtIndex:indexPath.row];
#if defined(__LP64__) && __LP64__
    cell.listNumLabel.text = [NSString stringWithFormat:@"%lu.",indexPath.row + 1];
#else
    cell.listNumLabel.text = [NSString stringWithFormat:@"%d.",indexPath.row + 1];
#endif
    if ([mu isEqual:[[YLAudioPlayer sharedAudioPlayer] currentPlayMusic]]) {
        cell.playStateImageView.image = [UIImage imageNamed:@"cellPlayState"];
    }else{
        cell.playStateImageView.image = nil;
    }
    
    cell.musicTitleLabel.text = mu.trackName;
    NSString *artistName = mu.artistName;
    if (mu.artistName ==nil || [mu.artistName isEmpty]) {
        artistName = PTNSLocalizedString(@"UnknowMsgKey", nil);
    }
    
    NSString *albumName = mu.albumName;
    if (mu.albumName ==nil || [mu.albumName isEmpty]) {
        albumName = PTNSLocalizedString(@"UnknowMsgKey", nil);
    }
    cell.musicDescLabel.text = [NSString stringWithFormat:@"%@ · %@",artistName,albumName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerPlaylistCell" forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [YLAudioPlayer sharedAudioPlayer].currentTrack = indexPath.row;
    [[YLAudioPlayer sharedAudioPlayer] reloadDataPlay];
    [self showOrHidePurchaseView];
    [tableView reloadData];
}

#pragma mark - private methods

- (void)showOrHidePurchaseView {
    if ([YLAudioPlayer sharedAudioPlayer].currentPlayMusic.sid) {
        [self.shareView setHidden:NO];
    } else {
        [self.shareView setHidden:YES];
    }
    if ([YLAudioPlayer sharedAudioPlayer].currentPlayMusic.source == MusicSourceSoundCloud) {
        [self.purchaseView setHidden:YES];
    } else if ([YLAudioPlayer sharedAudioPlayer].currentPlayMusic.source == MusicSourceiTunes){
        NSString *buyURL = [YLAudioPlayer sharedAudioPlayer].currentPlayMusic.purchaseUrl;
        if (self.purchaseView.isHidden) {
            if (buyURL) {
                [self.purchaseView setHidden:NO];
            } else {
                [self.purchaseView setHidden:YES];
            }
        }
    }
}

- (void)addActionToPurchaseAndShareViews {
    UITapGestureRecognizer *purchaseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(purchaseAction:)];
    [self.purchaseView addGestureRecognizer:purchaseGesture];
    UITapGestureRecognizer *shareGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareAction:)];
    [self.shareView addGestureRecognizer:shareGesture];
}
@end
