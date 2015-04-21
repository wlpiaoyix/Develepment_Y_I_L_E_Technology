//
//  HistoryTableViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "HistoryTableViewCell.h"

@implementation HistoryTableViewCell
@synthesize delegate=delegate;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteSearchKey:)]) {
        [self.delegate deleteSearchKey:self.aIndexPathRow];
    }
}
@end
