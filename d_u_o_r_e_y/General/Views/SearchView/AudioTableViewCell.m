//
//  AudioTableViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "AudioTableViewCell.h"

@implementation AudioTableViewCell
@synthesize delegate=delegate;

- (void)awakeFromNib {
    // Initialization code
    self.balancerView.strokeColor = [UIColor colorWithRed:66.0f/255.0f green:199.0f/255.0f blue:93.0f/255.0f alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addButtonAction:)]) {
        [self.delegate addButtonAction:self.aIndexPath];
    }
}
@end
