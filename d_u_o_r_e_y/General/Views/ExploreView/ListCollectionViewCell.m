//
//  ListCollectionViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ListCollectionViewCell.h"
#import "PTDefinitions.h"
#import "UIImageView+WebCache.h"

@interface ListCollectionViewCell ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *subNameLabel;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIImageView *countBGView;
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UIImageView *noView;

@end

@implementation ListCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup
- (void)setup
{
    [self setupView];
    [self setupLabel];
    [self setImageView];
}

- (void)setupView
{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setupLabel
{
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height+10, self.frame.size.height/2-20,  self.frame.size.width-self.frame.size.height+10, 20)];
    self.label.font=[UIFont fontWithName:@"HelveticaNeue" size:17];
    [self addSubview:self.label];
    
    self.subNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height+10, self.frame.size.height/2, self.frame.size.width-self.frame.size.height+10, 20)];
    self.subNameLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
    [self addSubview:self.subNameLabel];
    self.subNameLabel.textColor = UIColorFromHex(0x929292);
}

- (void)setImageView{
    _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
    [_mainImageView setImage:[UIImage imageNamed:@"icon_top"]];
    [self addSubview:_mainImageView];
    
    UIImageView *jiantouImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-20, self.frame.size.height/2-15, 15, 30)];
    [jiantouImageView setImage:[UIImage imageNamed:@"IconArrowDetail"]];
    [self addSubview:jiantouImageView];
}

#pragma mark - Configure
- (void)setNameLabelWithStr:(NSString *)nameStr
{
    self.label.text = nameStr;
}

- (void)setSubNameLabelWithStr:(NSString *)nameStr
{
    self.subNameLabel.text = nameStr;
}

- (void)setMainImageViewWithImageName:(NSString *)imageNameStr {
    [self.mainImageView setImage:[UIImage imageNamed:imageNameStr]];
}

- (void)setMainImageViewWithImageUrlString:(NSURL *)imageUrlString {
    [self.mainImageView sd_setImageWithURL:imageUrlString placeholderImage:[UIImage imageNamed:@"icon_top"]];
}
@end
