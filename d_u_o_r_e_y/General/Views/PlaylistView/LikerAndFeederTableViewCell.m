//
//  LikerAndFeederTableViewCell.m
//  Duorey
//
//  Created by lixu on 14/12/4.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "LikerAndFeederTableViewCell.h"

@implementation LikerAndFeederTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
