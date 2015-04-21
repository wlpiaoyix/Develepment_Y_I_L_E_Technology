//
//  PlaylistItunesTableViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/18.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "BalancerView.h"
#import "TapActionLabel.h"

@class PlaylistItunesTableViewCell;

@protocol PlaylistItunesTableViewCellDelegate <NSObject>

- (void)selectUserNameActionWithIndexPathRow:(NSInteger)aIndexPathRow;

- (void)playlistItunesTableViewCellActionButtonClicked:(PlaylistItunesTableViewCell *)cell;

@end

@interface PlaylistItunesTableViewCell : UITableViewCell

@property (strong, nonatomic) id<PlaylistItunesTableViewCellDelegate> aDelegate;
@property (nonatomic, assign) NSInteger aIndexPathRow;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet TapActionLabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet BalancerView *balancerView;
@property (weak, nonatomic) IBOutlet UIImageView *fromIconImageView;

@end
