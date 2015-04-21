//
//  OtherProfileCell.m
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "OtherProfileFollowCell.h"
#import "PTDefinitions.h"

@implementation OtherProfileFollowCell

@synthesize followed = _followed;

+ (NSString *)xibName{
    return NSStringFromClass(self.class);
}

+ (NSString *)reuseIdentifier
{
    return [NSString stringWithFormat:@"%@Identifier",NSStringFromClass(self.class)];
}

+ (CGFloat)cellHeight
{
    return 50.0;
}

- (void)awakeFromNib {
    // Initialization code
    self.followTitleLabel.text = PTNSLocalizedString(@"FollowButtonMsgKey", nil);
    self.followedTitleLabel.text = PTNSLocalizedString(@"FollowedButtonMsgKey", nil);
    self.followCountLabel.text = @"0";
    self.followedCountLabel.text = @"0";
    
    UITapGestureRecognizer *followGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followTouchAction:)];
    [self.followView addGestureRecognizer:followGR];
    
    UITapGestureRecognizer *followedGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followedTouchAction:)];
    [self.followedView addGestureRecognizer:followedGR];
    
    self.addFollowButton.hidden = NO;
    self.unFollowButton.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFollowed:(BOOL)followed{
    _followed = followed;
    if (followed) {
        self.addFollowButton.hidden = YES;
        self.unFollowButton.hidden = NO;
    }else{
        self.addFollowButton.hidden = NO;
        self.unFollowButton.hidden = YES;
    }
}

#pragma mark - Action

- (IBAction)followTouchAction:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(otherFollowClickAction:)]) {
        [self.delegate otherFollowClickAction:self];
    }
}

- (IBAction)followedTouchAction:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(otherFollowedClickAction:)]) {
        [self.delegate otherFollowedClickAction:self];
    }
}

- (IBAction)addFollowButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(addFollowClickAction:)]) {
        [self.delegate addFollowClickAction:self];
    }
}

- (IBAction)unFollowButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(unFollowClickAction:)]) {
        [self.delegate unFollowClickAction:self];
    }
}


@end
