//
//  ListCollectionViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCollectionViewCell : UICollectionViewCell

- (void)setNameLabelWithStr:(NSString *)nameStr;
- (void)setSubNameLabelWithStr:(NSString *)nameStr;
- (void)setMainImageViewWithImageName:(NSString *)imageNameStr;
- (void)setMainImageViewWithImageUrlString:(NSURL *)imageUrlString;
@end
