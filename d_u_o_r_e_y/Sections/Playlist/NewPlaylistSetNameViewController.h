//
//  NewPlaylistSetNameViewController.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewPlaylistSetNameViewControllerDelegate <NSObject>

- (void)doDismissView;

@end

@interface NewPlaylistSetNameViewController : UIViewController

@property (strong, nonatomic) id<NewPlaylistSetNameViewControllerDelegate> delegate;
@property (weak,nonatomic) NSString *whereF;
@property (copy,nonatomic) NSDictionary *musicDic;

@end
