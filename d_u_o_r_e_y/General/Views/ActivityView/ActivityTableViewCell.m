//
//  ActivityTableViewCell.m
//  Acticity
//
//  Created by ice on 14/11/27.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import "ActivityTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "PTUtilities.h"
#import "YLAudioPlayer.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TapActionLabel.h"
#import <UALogger.h>

@interface ActivityTableViewCell ()
{
    UITapGestureRecognizer *tapPlaySongGesture;
    UITapGestureRecognizer *firstTapGesture;
    UITapGestureRecognizer *lastTapGesture;
}
@property (nonatomic,weak) IBOutlet UIImageView *userHeaderImageView;
@property (nonatomic,weak) IBOutlet UIImageView *songImageView;
@property (nonatomic,weak) IBOutlet TapActionLabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *actionLabel;
@property (nonatomic,weak) IBOutlet TapActionLabel *subLabel;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet UILabel *songNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *songInfoLabel;
@property (nonatomic,weak) IBOutlet UIButton *playButton;
@property (nonatomic,weak) IBOutlet UIButton *addButton;
@property (nonatomic,weak) NSIndexPath *indexPath;
@property (nonatomic,strong) ActivityObj *activityObj;
@property (nonatomic,strong) UserAccount *user;
@property (nonatomic,weak) IBOutlet UIView *songContentView;
@end

@implementation ActivityTableViewCell

- (UserAccount *)userAccount{
    return [PTUtilities unarchiveObjectWithName:@"me"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
    [self resetSomething];
    self.userHeaderImageView.layer.cornerRadius = self.userHeaderImageView.bounds.size.height/2.0f;
    self.userHeaderImageView.clipsToBounds = YES;
    self.playButton.hidden = YES;
    self.addButton.hidden = YES;
}

-(void)resetSomething
{
    self.actionLabel.text = nil;
    self.subLabel.text = nil;
    self.nameLabel.text = nil;
    self.timeLabel.text = nil;
    self.songNameLabel.text = nil;
    self.songInfoLabel.text = nil;
    [self.playButton setImage:[UIImage imageNamed:@"cellPlayButton"] forState:UIControlStateNormal];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self resetSomething];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)commonInit{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop:) name:STOP_BALANCER_ANIMATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(start:) name:START_BALANCER_ANIMATION object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)start:(NSNotification *)notification
{
    if (self.activityObj.music)
    {
        if ([notification.object isEqual:self.activityObj.music])
        {
            [self.playButton setImage:[UIImage imageNamed:@"cellPauseButton"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"cellPlayButton"] forState:UIControlStateNormal];
    }

}

-(void)stop:(NSNotification *)notification
{
    [self.playButton setImage:[UIImage imageNamed:@"cellPlayButton"] forState:UIControlStateNormal];
}

- (void)playCurrentMusic
{
    if (self.activityObj.music)
    {
        if ([[YLAudioPlayer sharedAudioPlayer].currentPlayMusic isEqual:self.activityObj.music] && [YLAudioPlayer sharedAudioPlayer].isPlaying)
        {
            [self.playButton setImage:[UIImage imageNamed:@"cellPauseButton"] forState:UIControlStateNormal];
        }
        else
        {
            [self.playButton setImage:[UIImage imageNamed:@"cellPlayButton"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"cellPlayButton"] forState:UIControlStateNormal];
    }
}

-(IBAction)playAction:(UIButton *)sender
{
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(activityCellPlaySong:)]) {
        [_cellDelegate activityCellPlaySong:self.activityObj];
    }
}

-(IBAction)addAction:(UIButton *)sender
{
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(activityCellAddSong:)]) {
        [_cellDelegate activityCellAddSong:self.activityObj];
    }
}

-(void)showLabelText:(ActivityObj *)obj
{
    if(obj.music)
    {
        self.songNameLabel.text = obj.music.trackName;
        self.songInfoLabel.text = [NSString stringWithFormat:@"%@·%@",obj.music.artistName,obj.music.albumName];
    }
    
    if ([obj.activityType integerValue] == ActivityTypeAddSongToPlayList)
    {
        //添加歌到歌单
        self.nameLabel.text = self.user.nickname;
        self.actionLabel.text = PTNSLocalizedString(@"AddedSongToMsgKey", nil);
        self.subLabel.text = obj.playList.listName;
    }
    else if ([obj.activityType integerValue] == ActivityTypeListen)
    {
        //听歌
        self.nameLabel.text = self.user.nickname;
        self.actionLabel.text = PTNSLocalizedString(@"ListenedMsgKey", nil);
        self.subLabel.text = nil;
    }
    else if ([obj.activityType integerValue] == ActivityTypeCommentPlayList)
    {
        //评论歌单
        self.nameLabel.text = self.user.nickname;
        self.actionLabel.text = PTNSLocalizedString(@"FeededMsgKey", nil);
        self.subLabel.text = nil;
        if (obj.playList) {
            self.songNameLabel.text = obj.playList.listName;
            self.songInfoLabel.text = [NSString stringWithFormat:PTNSLocalizedString(@"PlaylistDetailMsgKey", nil),obj.playList.totalNum,obj.playList.playCountNum];
        }
    }
    else if ([obj.activityType integerValue] == ActivityTypeDeleteSongFromPlayList)
    {
        //从歌单删除歌
        self.nameLabel.text = self.user.nickname;
        self.actionLabel.text = PTNSLocalizedString(@"DeletedSongFromMsgKey", nil);
        self.subLabel.text = obj.playList.listName;
    }
    else if ([obj.activityType integerValue] == ActivityTypeFollowPlayList)
    {
        //关注歌单
        self.nameLabel.text = self.user.nickname; 
        self.actionLabel.text = PTNSLocalizedString(@"SubscribedMsgKey", nil);
        self.subLabel.text = nil;
        if (obj.playList) {
            self.songNameLabel.text = obj.playList.listName;
            self.songInfoLabel.text = [NSString stringWithFormat:PTNSLocalizedString(@"PlaylistDetailMsgKey", nil),obj.playList.totalNum,obj.playList.playCountNum];
        }
    }

}

-(void)showHeaderImage:(ActivityObj *)obj
{
    NSURL *userHeadUrl = nil;
    NSURL *songHeadUrl = nil;
    if (obj.music) {
        songHeadUrl = obj.music.artworkUrlBigger;
    }
    else
    {
        if (obj.playList) {
            songHeadUrl = [NSURL URLWithString:obj.playList.listIcon];
        }
    }
    
    userHeadUrl = self.user.userAvatarImageLargeURL;
    
    [self.userHeaderImageView sd_setImageWithURL:userHeadUrl placeholderImage:[UIImage imageNamed:@"cellAvatarImage"]];
    [self.songImageView sd_setImageWithURL:songHeadUrl placeholderImage:[UIImage imageNamed:@"DefaultCoverActivity"]];
}

-(void)showButton:(ActivityObj *)obj
{
    if ([obj.activityType integerValue] == ActivityTypeListen || [obj.activityType integerValue] == ActivityTypeAddSongToPlayList || [obj.activityType integerValue] == ActivityTypeDeleteSongFromPlayList)
    {
        self.addButton.hidden = NO;
        self.playButton.hidden = NO;
        if (!tapPlaySongGesture)
        {
            tapPlaySongGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAction:)];
            [self.songContentView addGestureRecognizer:tapPlaySongGesture];
        }
    }
    else
    {
        if (tapPlaySongGesture) {
            [self.songContentView removeGestureRecognizer:tapPlaySongGesture];
            tapPlaySongGesture = nil;
        }
        self.addButton.hidden = YES;
        self.playButton.hidden = YES;
    }

}

-(void)addTapGesture
{
    self.nameLabel.tapTarget = self;
    self.nameLabel.tapAction = @selector(tapFirstArea);
    
    self.subLabel.tapTarget = self;
    self.subLabel.tapAction = @selector(tapLastArea);
}

-(void)tapFirstArea
{
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(activityCellClickedUser:)]) {
        [_cellDelegate activityCellClickedUser:self.user];
    }
}

-(void)tapLastArea
{
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(activityCellClickPlayList:)])
    {
        [_cellDelegate activityCellClickPlayList:self.activityObj.playList];
    }
}

-(void)loadCellData:(ActivityObj *)obj
{
    self.activityObj = obj;
    if (obj.music)
    {
        [self playCurrentMusic];
    }
    
    if (obj.user) {
        self.user = obj.user;
    }
    else
        self.user = [self userAccount];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:obj.creatTime];
    self.timeLabel.text = [date timeAgo];
    
    [self addTapGesture];
    [self showButton:obj];
    [self showHeaderImage:obj];
    [self showLabelText:obj];
}
@end
