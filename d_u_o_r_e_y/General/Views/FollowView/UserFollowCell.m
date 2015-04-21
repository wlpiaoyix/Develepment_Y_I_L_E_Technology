//
//  UserFollowCell.m
//  Duorey
//
//  Created by xdy on 14/11/28.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "UserFollowCell.h"

@implementation UserFollowCell

+ (NSString *)xibName{
    return NSStringFromClass(self.class);
}

+ (NSString *)reuseIdentifier
{
    return [NSString stringWithFormat:@"%@Identifier",NSStringFromClass(self.class)];
}

+ (CGFloat)cellHeight
{
    return 44.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
