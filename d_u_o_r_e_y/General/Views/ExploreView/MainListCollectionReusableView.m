//
//  MainListCollectionReusableView.m
//  Duorey
//
//  Created by lixu on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "MainListCollectionReusableView.h"
#import "PTDefinitions.h"

@interface MainListCollectionReusableView ()

@property (nonatomic) UIImageView *iconImageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UIButton *moreButton;
@property (nonatomic) UIImageView *jiantouImageView;

@end

@implementation MainListCollectionReusableView
@synthesize delegate=delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)loadView{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
    [aView setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]];
    [self addSubview:aView];
    
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 20, 20)];
    [self addSubview:_iconImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, self.frame.size.width-100, 20)];
    _nameLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:17];
    [self addSubview:_nameLabel];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moreButton.tag = self.aTag;
    [_moreButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:17]];
    [_moreButton setFrame:CGRectMake(self.frame.size.width-65, 15, 50, 30)];
    [_moreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_moreButton setTitle:PTNSLocalizedString(@"MoreButtonMsgKey", nil) forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreButton];
    
    _jiantouImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-15, 22, 8, 15)];
    [_jiantouImageView setImage:[UIImage imageNamed:@"jiantou"]];
    [self addSubview:_jiantouImageView];
}

- (void)setIconImageWithImageName:(NSString *)imageNameStr{
    [_iconImageView setImage:[UIImage imageNamed:imageNameStr]];
}

- (void)setNameLabelWithNaemStr:(NSString *)nameStr{
    [_nameLabel setText:nameStr];
}

- (void)moreButtonAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(moreButtonAction:)]) {
        [self.delegate moreButtonAction:self.aTag];
    }
}

- (void)setMoreButtonHidden:(BOOL )isHidden{
    [_moreButton setHidden:isHidden];
}

- (void)setJianTouHidden:(BOOL )isHidden{
    [_jiantouImageView setHidden:isHidden];
}
@end
