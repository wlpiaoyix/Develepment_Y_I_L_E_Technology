//
//  OtherProfileCell.h
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OtherProfileFollowCell;

@protocol OtherProfileFollowCellDelegate <NSObject>

@required
- (void)otherFollowClickAction:(OtherProfileFollowCell *)cell;
- (void)otherFollowedClickAction:(OtherProfileFollowCell *)cell;

@optional
- (void)unFollowClickAction:(OtherProfileFollowCell *)cell;
- (void)addFollowClickAction:(OtherProfileFollowCell *)cell;
@end

@interface OtherProfileFollowCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *followView;
@property (weak, nonatomic) IBOutlet UIView *followedView;

@property (weak, nonatomic) IBOutlet UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *followedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followedTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *addFollowButton;
@property (weak, nonatomic) IBOutlet UIButton *unFollowButton;

@property (assign, nonatomic, getter=isFollowed) BOOL followed;
@property (weak, nonatomic) id<OtherProfileFollowCellDelegate> delegate;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end
