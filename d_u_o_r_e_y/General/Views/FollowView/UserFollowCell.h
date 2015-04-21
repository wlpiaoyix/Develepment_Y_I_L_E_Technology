//
//  UserFollowCell.h
//  Duorey
//
//  Created by xdy on 14/11/28.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserFollowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNickNameLabel;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;

@end
