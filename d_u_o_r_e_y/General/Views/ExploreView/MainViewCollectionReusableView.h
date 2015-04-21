//
//  MainViewCollectionReusableView.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainViewCollectionReusableViewDelegate <NSObject>

- (void)clickImageViewCount:(int)imageViewCount;

@end

@interface MainViewCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) id<MainViewCollectionReusableViewDelegate> delegate;
- (void)setImageViewWithImage:(NSMutableArray *)arr;

@end
