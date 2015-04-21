//
//  MainListCollectionReusableView.h
//  Duorey
//
//  Created by lixu on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainListCollectionReusableViewDeleagte <NSObject>

- (void)moreButtonAction:(int)aTag;

@end

@interface MainListCollectionReusableView : UICollectionReusableView

@property ( nonatomic) int aTag;
@property (strong, nonatomic) id<MainListCollectionReusableViewDeleagte> delegate;
- (void)setIconImageWithImageName:(NSString *)imageNameStr;
- (void)setNameLabelWithNaemStr:(NSString *)nameStr;
- (void)setMoreButtonHidden:(BOOL )isHidden;
- (void)setJianTouHidden:(BOOL )isHidden;

@end
