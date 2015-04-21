//
//  MainViewCollectionReusableView.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "MainViewCollectionReusableView.h"
#import "UIImageView+WebCache.h"
#import "MainViewObj.h"
#import "ItunesTableViewController.h"
#import "PTUtilities.h"

@interface MainViewCollectionReusableView ()<UIScrollViewDelegate>{
    UIImageView* _viewFirst;
    UIImageView* _viewSecond;
    UIImageView* _viewThird;
    int _timCount;
    int _allCount;
    BOOL isBig;
    NSTimer *_timer;
}
@property ( nonatomic) UIScrollView *scrollView;
@property ( nonatomic) UIPageControl *pageControl;
@end

@implementation MainViewCollectionReusableView
@synthesize delegate=delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)loadView{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 150)];
    _scrollView.userInteractionEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    CGSize sizePageControl = CGSizeMake(120, 20);

    CGRect framePageControl = CGRectMake((self.frame.size.width-sizePageControl.width)/2, (150-sizePageControl.height), sizePageControl.width, sizePageControl.height);
    _pageControl = [[UIPageControl alloc] initWithFrame:framePageControl];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.numberOfPages = 3;
    
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
    
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(_scrollView.contentOffset.x)/self.frame.size.width;
    _pageControl.currentPage = index;
    _timCount=index;
    if (_timCount==_allCount-1) {
        isBig=YES;
    }
    if (_timCount==0) {
        isBig=NO;
    }
    if (_timer) {
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                             target:self
                                           selector:@selector(scrollTimer)
                                           userInfo:nil
                                            repeats:YES];
}

-(void)scrollTimer{
    if (!isBig) {
        _timCount++;
    }else{
        _timCount--;
    }
    if (_timCount==_allCount-1) {
        isBig=YES;
    }
    if (_timCount==0) {
        isBig=NO;
    }
//    if (_timCount == _allCount) {
//        _timCount = 0;
//    }
    [_scrollView scrollRectToVisible:CGRectMake(_timCount * self.frame.size.width, 65.0, self.frame.size.width, 150) animated:YES];
    
    _pageControl.currentPage = _timCount;
}

- (void)setImageViewWithImage:(NSMutableArray *)arr{
    _allCount = (int)[arr count];
    _pageControl.numberOfPages = _allCount;
    if (_allCount>0) {
        if (_timer) {
            [_timer invalidate];
        }
         _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(scrollTimer)
                                               userInfo:nil
                                                repeats:YES];
    }
    for (int i=0;i<[arr count];i++) {
        CGRect frame = self.frame;
        float x = i*frame.size.width;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, frame.origin.y, frame.size.width, frame.size.height)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        NSString *listIconStr = ((MainViewObj *)[arr objectAtIndex:i]).listIcon;
        if([PTUtilities isEmptyOrNull:listIconStr]) listIconStr = @" ";
        if (![PTUtilities isEmptyOrNull:listIconStr]) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:listIconStr]
                         placeholderImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];
        }else{
            [imageView setImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];
        }
        imageView.tag=i;
        [imageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(imageViewClick:)];
        [imageView addGestureRecognizer:singleTap];
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake(self.frame.size.width*[arr count], self.frame.size.height);
}

- (void)imageViewClick:(id)sender{
    if ([self.delegate respondsToSelector:@selector(clickImageViewCount:)]) {
        [self.delegate clickImageViewCount:(int)_pageControl.currentPage];
    }
}

@end
