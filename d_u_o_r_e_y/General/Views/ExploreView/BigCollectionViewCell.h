//
//  BigCollectionViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigCollectionViewCell : UICollectionViewCell

- (void)setNameLabelWithStr:(NSString *)nameStr;
- (void)setCountLabelWithStr:(NSString *)countStr;
- (void)setNoImageViewWithImageName:(NSString *)imageNameStr;
- (void)setMainImageViewWithImageUrl:(NSURL *)aImageUrl;

@end
