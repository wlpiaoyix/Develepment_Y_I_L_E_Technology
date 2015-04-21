//
//  ProfileFollowCell.m
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ProfileFollowCell.h"
#import "PTDefinitions.h"

@interface ProfileFollowCell()

@property (weak, nonatomic) IBOutlet UIView *followView;
@property (weak, nonatomic) IBOutlet UIView *followedView;


@end

@implementation ProfileFollowCell

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)followTouchAction:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(sysFollowClickAction:)]) {
        [self.delegate sysFollowClickAction:self];
    }
}

- (IBAction)followedTouchAction:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(sysFollowedClickAction:)]) {
        [self.delegate sysFollowedClickAction:self];
    }
}

@end
