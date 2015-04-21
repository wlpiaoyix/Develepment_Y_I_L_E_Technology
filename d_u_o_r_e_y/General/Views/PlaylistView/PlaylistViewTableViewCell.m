//
//  PlaylistViewTableViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistViewTableViewCell.h"

@implementation PlaylistViewTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.mainIamgeView setContentMode:UIViewContentModeScaleToFill];
    [self.mainIamgeView setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
