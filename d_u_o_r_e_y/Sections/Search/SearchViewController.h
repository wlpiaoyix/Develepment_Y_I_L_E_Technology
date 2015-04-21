//
//  SearchViewController.h
//  Duorey
//
//  Created by lixu on 14/11/10.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"

@protocol SearchViewControllerDelegate <NSObject>

- (void)creatPlaylistBack;

@end

@interface SearchViewController : UIViewController

@property (strong, nonatomic) id<SearchViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *whereF;

@end
