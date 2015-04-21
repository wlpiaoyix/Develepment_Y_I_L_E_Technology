//
//  AboutViewController.m
//  Duorey
//
//  Created by xdy on 14/12/2.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "AboutViewController.h"
#import "PTUtilities.h"
#import "PTDefinitions.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;


@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView{
    self.title = PTNSLocalizedString(@"AboutTitleMsgKey", nil);
    self.titleLabel.text = PTNSLocalizedString(@"AppNameMsgKey", nil);
    self.titleDetailLabel.text = PTNSLocalizedString(@"AppDetailMsgKey", nil);
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:PTNSLocalizedString(@"AppVersionMsgKey", nil),version];
    self.copyrightLabel.text = PTNSLocalizedString(@"AppCopyrightMsgKey", nil);
}

@end
