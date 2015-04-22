//
//  ProfileInfoView.m
//  Duorey
//
//  Created by xdy on 14/11/11.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ProfileInfoView.h"

@implementation ProfileInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    return self;
}
@end