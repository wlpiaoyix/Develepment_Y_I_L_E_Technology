//
//  ItunesTableViewController.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItunesTableViewController : UITableViewController

@property ( nonatomic) int listId;
@property (weak, nonatomic) NSString *whereF;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *headerCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *likerLabel;
@property (weak, nonatomic) IBOutlet UILabel *feederLabel;
@property (weak, nonatomic) IBOutlet UIButton *goodButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)goodButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;
- (IBAction)playButtonAction:(id)sender;
@end
