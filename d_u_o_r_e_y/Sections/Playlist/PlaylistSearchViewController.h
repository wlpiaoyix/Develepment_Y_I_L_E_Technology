//
//  PlaylistSearchViewController.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaylistSearchViewControllerDelegate <NSObject>

- (void)creatPlaylistBack;

@end

@interface PlaylistSearchViewController : UIViewController

@property (strong, nonatomic) id<PlaylistSearchViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *whereF;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UITableView *hisTableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

@end
