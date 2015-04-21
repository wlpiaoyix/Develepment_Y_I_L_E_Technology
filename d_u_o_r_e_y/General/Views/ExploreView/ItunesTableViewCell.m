//
//  ItunesTableViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ItunesTableViewCell.h"

@implementation ItunesTableViewCell
@synthesize delegate=delegate;

- (void)awakeFromNib {
    // Initialization code
//    [self.playBuleImageView setHidden:YES];
    self.balancerView.strokeColor = [UIColor colorWithRed:66.0f/255.0f green:199.0f/255.0f blue:93.0f/255.0f alpha:1];
//    self.iconImageView.layer.masksToBounds = YES;
//    self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)moreButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(moreButtonActionWithIndex:)]) {
        [self.delegate moreButtonActionWithIndex:self.aIndexPathRow];
    }
}
@end
