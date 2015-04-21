//
//  PlaylistItunesTableViewController.h
//  Duorey
//
//  Created by lixu on 14/11/18.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistObj.h"

@protocol PlaylistItunesTableViewControllerDelegate <NSObject>

- (void)playlistItunesDisMissView;

@end

@interface PlaylistItunesTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (copy, nonatomic) PlaylistObj *playlistObj;
@property (copy, nonatomic) NSString *listId;
@property (copy, nonatomic) NSString *whereF;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *headerCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *likerLabel;
@property (weak, nonatomic) IBOutlet UILabel *feederLabel;
@property (weak, nonatomic) IBOutlet UILabel *likerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *feederNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *goodButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) id<PlaylistItunesTableViewControllerDelegate> delegate;
- (IBAction)likerButtonAction:(id)sender;
- (IBAction)feederButtonAction:(id)sender;


- (IBAction)goodButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;
- (IBAction)playButtonAction:(id)sender;

@end
