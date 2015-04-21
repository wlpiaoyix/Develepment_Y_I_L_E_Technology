//
//  AddMusicToPlaylistViewController.h
//  Duorey
//
//  Created by lixu on 14/11/20.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RssAppleMusic.h"
#import "SoundCloudMusic.h"

@class AddMusicToPlaylistViewController;
@protocol AddMusicToPlaylistViewControllerDelegate <NSObject>

- (void)addMusicToPlaylistCancelButtonAction:(AddMusicToPlaylistViewController *)addMusicToPlaylistVC;

@end

@interface AddMusicToPlaylistViewController : UIViewController

@property (strong, nonatomic) id<AddMusicToPlaylistViewControllerDelegate> delegate;
@property (copy, nonatomic) NSDictionary *playlistObjDic;

@end
