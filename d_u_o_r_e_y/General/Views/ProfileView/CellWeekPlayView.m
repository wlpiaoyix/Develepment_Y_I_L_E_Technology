//
//  CellPlayView.m
//  ViewDemo
//
//  Created by xdy on 14/11/26.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "CellWeekPlayView.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface CellWeekPlayView ()

@property (strong, nonatomic) UIView *playView;
@property (strong, nonatomic) UIImageView *playBackgroundImageView;
@property (strong, nonatomic) UIImageView *playStatusImageView;
@property (strong, nonatomic) UILabel *musicTitleLable;
@property (assign, nonatomic,getter=isCurrentPlaying) BOOL currntPlaying;
@property (nonatomic, strong) UIImage *playImage;
@property (nonatomic, strong) UIImage *pauseImage;
@end

@implementation CellWeekPlayView

@synthesize currntPlaying = _currntPlaying;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    self.playImage = [UIImage imageNamed:@"cellPlayButton"];
    self.pauseImage = [UIImage imageNamed:@"cellPauseButton"];
    _currntPlaying = NO;
    addNotificationObserver(START_BALANCER_ANIMATION, self, @selector(musicPlayStart:), nil);
    addNotificationObserver(STOP_BALANCER_ANIMATION, self, @selector(musicPlayStop:), nil);
//    addNotificationObserver(MusicPlayCellWeekPlayViewStartingNotification, self, @selector(musicPlayStarting:), nil);
//    addNotificationObserver(MusicPlayCellWeekPlayViewStopNotification, self, @selector(musicStop:), nil);
}

//- (void)musicStop:(NSNotification *)notif {
//    self.playStatusImageView.image = self.playImage;
//}

- (void)musicPlayStart:(NSNotification *)notif {
    Music *music = (Music *)[notif object];
    _currntPlaying = YES;
    if ([music isEqual:_music]) {
        self.playStatusImageView.image = self.pauseImage;
    }
}

- (void)musicPlayStop:(NSNotification *)notif {
    _currntPlaying = NO;
    self.playStatusImageView.image = self.playImage;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!self.playView) {
        self.playView = [[UIView alloc] initWithFrame:CGRectZero];
        UITapGestureRecognizer *playRG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playCurrentMusic)];
        [self.playView addGestureRecognizer:playRG];
        [self addSubview:self.playView];
    }
    
    self.playView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.7);
    
    if (!self.playBackgroundImageView) {
        self.playBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.playBackgroundImageView.clipsToBounds = YES;
        self.playBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.playBackgroundImageView.image = [UIImage imageNamed:@"DefaultTopCover"];
        [self.playView addSubview:self.playBackgroundImageView];
        
    }
    
    self.playBackgroundImageView.frame = self.playView.frame;
    
    if (!self.musicTitleLable) {
        self.musicTitleLable = [[UILabel alloc] initWithFrame:CGRectZero];
        self.musicTitleLable.textAlignment = NSTextAlignmentCenter;
        self.musicTitleLable.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        self.musicTitleLable.numberOfLines = 2;
        self.musicTitleLable.text = @"";
        [self addSubview:self.musicTitleLable];
    }
    
    self.musicTitleLable.frame = CGRectMake(0, CGRectGetHeight(self.playView.frame)+CGRectGetHeight(self.frame) * 0.05, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.2);
    
    if (!self.playStatusImageView) {
        self.playStatusImageView = [[UIImageView alloc] initWithImage:self.playImage];
        [self.playView insertSubview:self.playStatusImageView aboveSubview:self.playBackgroundImageView];
    }
    
    self.playStatusImageView.center = self.playView.center;
}

- (void)setMusic:(Music *)music{
    _music = music;
    if (_music) {
        self.hidden = NO;
        UIImage *image = [UIImage imageNamed:@"DefaultTopCover"];
        if (_music.artworkUrlBigger==nil) {
            [self.playBackgroundImageView setImage:image];
        }else{
            [self.playBackgroundImageView sd_setImageWithURL:_music.artworkUrlBigger placeholderImage:image];
        }
        if ([YLAudioPlayer sharedAudioPlayer].isPlaying) {
            if ([[YLAudioPlayer sharedAudioPlayer].currentPlayMusic isEqual:_music]) {
                self.playStatusImageView.image = self.pauseImage;
            }
        } else {
            if ([[YLAudioPlayer sharedAudioPlayer].currentPlayMusic isEqual:_music]) {
                self.playStatusImageView.image = self.playImage;
            }
        }
//        UIImage *imageStatus = self.playImage;
//        self.playStatusImageView.image = imageStatus;
        self.musicTitleLable.text = _music.trackName;
    }
}

#pragma mark - notification

//- (void)musicPlayStarting:(NSNotification *)notification{
//    Music *music = (Music *)[notification object];
//    if (![[YLAudioPlayer sharedAudioPlayer].currentPlayMusic isEqual:music]) {
//        self.playStatusImageView.image = self.pauseImage;
//    }
//}

#pragma mark - Action

- (void)playCurrentMusic{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"Click_I_pro" label:@"Most_play" value:nil];
    if (_music) {
        if ([YLAudioPlayer sharedAudioPlayer].isPlaying) {
            if ([[YLAudioPlayer sharedAudioPlayer].currentPlayMusic isEqual:_music]) {
                [[YLAudioPlayer sharedAudioPlayer] pause];
                self.playStatusImageView.image = self.playImage;
            } else {
                [[YLAudioPlayer sharedAudioPlayer] playCurrentTrack:_music];
                self.playStatusImageView.image = self.pauseImage;
            }
        } else {
            if ([[YLAudioPlayer sharedAudioPlayer].currentPlayMusic isEqual:_music]) {
                [[YLAudioPlayer sharedAudioPlayer] play];
            } else {
                [[YLAudioPlayer sharedAudioPlayer] playCurrentTrack:_music];
            }
            self.playStatusImageView.image = self.pauseImage;
        }
    }
}


@end
