//
//  MusicListCell.m
//  Duorey
//
//  Created by xdy on 14/11/26.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "MusicListCell.h"

@implementation MusicListCell

+ (NSString *)xibName{
    return NSStringFromClass(self.class);
}

+ (NSString *)reuseIdentifier
{
    return [NSString stringWithFormat:@"%@Identifier",NSStringFromClass(self.class)];
}

+ (CGFloat)cellHeight
{
    return 74.0;
}

- (void)awakeFromNib {
    // Initialization code
    [self.musicImageView setImage:[UIImage imageNamed:@"cellMusicListIcon"]];
    [self.musicSourceImageView setImage:[UIImage imageNamed:@"cellMusicTunes"]];
    self.balancerView.strokeColor = [UIColor colorWithRed:66.0f/255.0f green:199.0f/255.0f blue:93.0f/255.0f alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
