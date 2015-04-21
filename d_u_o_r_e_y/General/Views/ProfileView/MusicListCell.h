//
//  MusicListCell.h
//  Duorey
//
//  Created by xdy on 14/11/26.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BalancerView.h"
@interface MusicListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *musicImageView;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *musicSourceImageView;
@property (weak, nonatomic) IBOutlet UILabel *musicDetailLabel;
@property (weak, nonatomic) IBOutlet BalancerView *balancerView;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;

@end
