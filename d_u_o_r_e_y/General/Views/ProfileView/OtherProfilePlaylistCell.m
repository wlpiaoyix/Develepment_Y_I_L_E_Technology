//
//  OtherProfilePlayCell.m
//  Duorey
//
//  Created by xdy on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "OtherProfilePlaylistCell.h"
#import "PTDefinitions.h"
#import "CellPlaylistView.h"

@interface OtherProfilePlaylistCell (){
    PlaylistObj *_firstPlaylstObj;
    PlaylistObj *_secondPlaylstObj;
    PlaylistObj *_thirdPlaylstObj;
    PlaylistObj *_fourPlaylstObj;
}

@property (weak, nonatomic) IBOutlet CellPlaylistView *firstView;
@property (weak, nonatomic) IBOutlet CellPlaylistView *secondView;
@property (weak, nonatomic) IBOutlet CellPlaylistView *thirdView;
@property (weak, nonatomic) IBOutlet CellPlaylistView *fourView;

@end

@implementation OtherProfilePlaylistCell

@synthesize feedPlaylists = _feedPlaylists;

+ (NSString *)xibName{
    return NSStringFromClass(self.class);
}

+ (NSString *)reuseIdentifier
{
    return [NSString stringWithFormat:@"%@Identifier",NSStringFromClass(self.class)];
}

+ (CGFloat)cellHeight
{
    return 135.0;
}

- (void)awakeFromNib {
    // Initialization code
    self.playCellTitleLabel.text = PTNSLocalizedString(@"FeededPlaylistMsgKey", nil);
    self.playCellDetailLabel.text = PTNSLocalizedString(@"MoreButtonMsgKey", nil);
    self.firstView.hidden = YES;
    self.secondView.hidden = YES;
    self.thirdView.hidden = YES;
    self.fourView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFeedPlaylists:(NSArray *)feedPlaylists{
    if (feedPlaylists != nil && ![feedPlaylists isEqual:_feedPlaylists]) {
        _feedPlaylists = feedPlaylists;
        if ([_feedPlaylists count]<=4) {
            self.playCellDetailLabel.hidden = YES;
            self.smallArrowsImageView.hidden = YES;
        }else{
            self.playCellDetailLabel.hidden = NO;
            self.smallArrowsImageView.hidden = NO;
            UITapGestureRecognizer *showMoreGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMorePlaylist)];
            [self.feedTitleView addGestureRecognizer:showMoreGR];
        }
        
        for (int i=0; i<[feedPlaylists count]; i++) {
            if (i>3) {
                return;
            }
            
            if (i==0) {
                _firstPlaylstObj = feedPlaylists[i];
                [self.firstView setPlaylist:_firstPlaylstObj];
                [self.firstView addTouchUpInsideTarget:self action:@selector(firstViewAction)];
            }else if (i==1){
                _secondPlaylstObj = feedPlaylists[i];
                [self.secondView setPlaylist:_secondPlaylstObj];
                [self.secondView addTouchUpInsideTarget:self action:@selector(secondViewAction)];
            }else if (i==2){
                _thirdPlaylstObj = feedPlaylists[i];
                [self.thirdView setPlaylist:_thirdPlaylstObj];
                [self.thirdView addTouchUpInsideTarget:self action:@selector(thirdViewAction)];
            }else if (i==3){
                _fourPlaylstObj = feedPlaylists[i];
                [self.fourView setPlaylist:_fourPlaylstObj];
                [self.fourView addTouchUpInsideTarget:self action:@selector(fourViewAction)];
            }
        }
    }
}

#pragma mark - Action

- (void)showMorePlaylist{
    if ([self.delegate respondsToSelector:@selector(profilePlaylistCellShowMore:)]) {
        [self.delegate profilePlaylistCellShowMore:self];
    }
}

- (void)firstViewAction{
    if ([self.delegate respondsToSelector:@selector(profilePlaylistCell:playlistDetail:)] && _firstPlaylstObj) {
        [self.delegate profilePlaylistCell:self playlistDetail:_firstPlaylstObj];
    }
}

- (void)secondViewAction{
    if ([self.delegate respondsToSelector:@selector(profilePlaylistCell:playlistDetail:)] && _secondPlaylstObj) {
        [self.delegate profilePlaylistCell:self playlistDetail:_secondPlaylstObj];
    }
}

- (void)thirdViewAction{
    if ([self.delegate respondsToSelector:@selector(profilePlaylistCell:playlistDetail:)] && _thirdPlaylstObj) {
        [self.delegate profilePlaylistCell:self playlistDetail:_thirdPlaylstObj];
    }
}

- (void)fourViewAction{
    if ([self.delegate respondsToSelector:@selector(profilePlaylistCell:playlistDetail:)] && _fourPlaylstObj) {
        [self.delegate profilePlaylistCell:self playlistDetail:_fourPlaylstObj];
    }
}

@end
