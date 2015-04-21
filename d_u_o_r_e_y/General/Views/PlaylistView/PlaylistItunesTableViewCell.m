//
//  PlaylistItunesTableViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/18.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistItunesTableViewCell.h"

@implementation PlaylistItunesTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height/2;
    self.balancerView.strokeColor = [UIColor colorWithRed:66.0f/255.0f green:199.0f/255.0f blue:93.0f/255.0f alpha:1];
    self.userNameLabel.tapTarget = self;
    self.userNameLabel.tapAction = @selector(selectUserNameAction);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)selectUserNameAction{
    if ([self.aDelegate respondsToSelector:@selector(selectUserNameActionWithIndexPathRow:)]) {
        [self.aDelegate selectUserNameActionWithIndexPathRow:self.aIndexPathRow];
    }
}

- (IBAction)cellAction:(id)sender {
    if ([self.aDelegate respondsToSelector:@selector(playlistItunesTableViewCellActionButtonClicked:)]) {
        [self.aDelegate playlistItunesTableViewCellActionButtonClicked:self];
    }
}

@end
