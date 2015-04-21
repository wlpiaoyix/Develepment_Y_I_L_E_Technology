//
//  GridCollectionViewCell.m
//  Duorey
//
//  Created by lixu on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "GridCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "PTUtilities.h"

@interface GridCollectionViewCell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIImageView *countBGView;
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UIImageView *noView;
@end

@implementation GridCollectionViewCell

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
    [_mainImageView setImage:[UIImage imageNamed:@"DefaultCoverNo2"]];
    _mainImageView.clipsToBounds = YES;
    _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_mainImageView];
    
    _countBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 20)];
    [_countBGView setImage:[UIImage imageNamed:@"count_bg"]];
    [self addSubview:_countBGView];
    
    _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.frame.size.height-37, 15, 12)];
    [_headerView setImage:[UIImage imageNamed:@"headphones"]];
    [self addSubview:_headerView];
    
    _noView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 57, 57)];
    [self addSubview:_noView];
}

#pragma mark - Configure
- (void)setNameLabelWithStr:(NSString *)nameStr
{
    NSString *nameS = nameStr;
//    if ([nameStr length]>13) {
        if ([nameStr length]>=29) {
            nameS = [[nameStr substringToIndex:26] stringByAppendingString:@"..."];
        }else{
            for (int i=0; i<29-[nameStr length]; i++) {
                nameS = [nameS stringByAppendingString:@" "];
            }
        }
        [self.label setNumberOfLines:2];
        self.label.lineBreakMode = NSLineBreakByCharWrapping;
        [self.label sizeToFit];
        self.label.font=[UIFont fontWithName:@"HelveticaNeue" size:12];
        float cellHight = [self contentCellHeightWithText:nameS];
        if(cellHight>30)
            cellHight = 30;
        self.label.frame = CGRectMake(0, CGRectGetHeight(self.mainImageView.bounds), self.frame.size.width, cellHight);
//    }
    self.label.text = nameS;
}

- (CGFloat)contentCellHeightWithText:(NSString*)text{
    NSInteger ch;
    UIFont *font = [UIFont systemFontOfSize:12];//11 一定要跟label的显示字体大小一致
    //设置字体
    CGSize size = CGSizeMake(self.frame.size.width, 20000.0f);//注：这个宽：300 是你要显示的宽度既固定的宽度，高度可以依照自己的需求而定
    if ([PTUtilities isVersion7]){//IOS 7.0 以上
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
        size = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }else{
        size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];//ios7以上已经摒弃的这个方法
    }
    ch = size.height;
    return ch;
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
        [self.mainImageView sd_setImageWithURL:aImageUrl placeholderImage:[UIImage imageNamed:@"DefaultCoverNo2"]];
    }else{
        [self.mainImageView setImage:[UIImage imageNamed:@"DefaultCoverNo2"]];
    }
}

- (void)setNoCountImageViewHidden:(BOOL)isHidden{
    [_noView setHidden:isHidden];
}

@end
