//
//  BigCollectionViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "BigCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface BigCollectionViewCell ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIImageView *countBGView;
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UIImageView *noView;

@end

@implementation BigCollectionViewCell

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
    [self setImageView];
    [self setupLabel];
}

- (void)setupView
{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setupLabel
{
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20)];
    self.label.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
    [self addSubview:self.label];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, self.frame.size.height-38, self.frame.size.width, 15)];
    _countLabel.text=@"0";
    [_countLabel setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:12]];
    [_countLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:_countLabel];
}

- (void)setImageView{
    _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20)];
    [_mainImageView setImage:[UIImage imageNamed:@"DefaultCoverNo1"]];
    _mainImageView.clipsToBounds = YES;
    _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_mainImageView];
    
    _countBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 20)];
    [_countBGView setImage:[UIImage imageNamed:@"count_bg"]];
    [self addSubview:_countBGView];
    
    _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.frame.size.height-37, 15, 12)];
    [_headerView setImage:[UIImage imageNamed:@"headphones"]];
    [self addSubview:_headerView];
    
    _noView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 67, 67)];
    [self addSubview:_noView];
}

#pragma mark - Configure
- (void)setNameLabelWithStr:(NSString *)nameStr
{
    self.label.text = nameStr;
}

- (void)setCountLabelWithStr:(NSString *)countStr
{
    self.countLabel.text = countStr;
}

- (void)setNoImageViewWithImageName:(NSString *)imageNameStr
{
    [self.noView setImage:[UIImage imageNamed:imageNameStr]];
}

- (void)setMainImageViewWithImageUrl:(NSURL *)aImageUrl
{
    if (aImageUrl!=nil) {
        [self.mainImageView sd_setImageWithURL:aImageUrl  placeholderImage:[UIImage imageNamed:@"DefaultCoverNo1"]];
    }else{
        [self.mainImageView setImage:[UIImage imageNamed:@"DefaultCoverNo1"]];
    }
//    [self.mainImageView setImage:aImage];
}

@end
