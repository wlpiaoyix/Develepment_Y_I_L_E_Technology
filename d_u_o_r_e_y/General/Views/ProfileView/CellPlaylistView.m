//
//  CellPlaylistView.m
//  Duorey
//
//  Created by xdy on 14/11/26.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "CellPlaylistView.h"
#import "UIImageView+WebCache.h"

@interface CellPlaylistView(){
    UIView *_playlistView;
    UIImageView *_playlistBackgroundImageView;
    UILabel *_playlistTitleLable;
    UITapGestureRecognizer *_touchUpInsideTgr;
}

@end

@implementation CellPlaylistView

@synthesize playlist = _playlist;

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_playlistView) {
        _playlistView = [[UIView alloc] initWithFrame:CGRectZero];
        _touchUpInsideTgr = [[UITapGestureRecognizer alloc] init];
        [_playlistView addGestureRecognizer:_touchUpInsideTgr];
        [self addSubview:_playlistView];
    }
    
    _playlistView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.7);
    
    if (!_playlistBackgroundImageView) {
        _playlistBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _playlistBackgroundImageView.clipsToBounds = YES;
        _playlistBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _playlistBackgroundImageView.image = [UIImage imageNamed:@"DefaultTopCover"];
        [_playlistView addSubview:_playlistBackgroundImageView];
        
    }
    
    _playlistBackgroundImageView.frame = _playlistView.frame;
    
    if (!_playlistTitleLable) {
        _playlistTitleLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _playlistTitleLable.textAlignment = NSTextAlignmentCenter;
        _playlistTitleLable.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        _playlistTitleLable.numberOfLines = 2;
        _playlistTitleLable.text = @"";
        [self addSubview:_playlistTitleLable];
    }
    
    _playlistTitleLable.frame = CGRectMake(0, CGRectGetHeight(_playlistView.frame)+CGRectGetHeight(self.frame) * 0.05, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.2);
}

- (void)addTouchUpInsideTarget:(id)target action:(SEL)action{
    if (_touchUpInsideTgr) {
        [_touchUpInsideTgr addTarget:target action:action];
    }
}

- (void)setPlaylist:(PlaylistObj *)playlist{
    if (playlist!=nil && ![playlist isEqual:_playlist]) {
        _playlist = playlist;
        
        self.hidden = NO;
        UIImage *image = [UIImage imageNamed:@"DefaultTopCover"];
        if (playlist.listIcon==nil) {
            [_playlistBackgroundImageView setImage:image];
        }else{
            [_playlistBackgroundImageView sd_setImageWithURL:[NSURL URLWithString:playlist.listIcon] placeholderImage:image];
        }
        _playlistTitleLable.text = playlist.listName;
    }
}

@end
