//
//  ProfileFollowCell.h
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileFollowCell;

@protocol ProfileFollowCellDelegate <NSObject>

- (void)sysFollowClickAction:(ProfileFollowCell *)cell;
- (void)sysFollowedClickAction:(ProfileFollowCell *)cell;

@end

@interface ProfileFollowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *followedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followedTitleLabel;

@property (weak, nonatomic) id<ProfileFollowCellDelegate> delegate;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end
