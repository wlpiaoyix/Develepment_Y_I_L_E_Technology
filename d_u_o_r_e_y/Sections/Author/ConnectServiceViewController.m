//
//  MusicAuthorizationViewController.m
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ConnectServiceViewController.h"
#import "PTDefinitions.h"
#import "UserAccount.h"
#import "PTUtilities.h"
#import "AuthorizationViewController.h"
#import <UALogger.h>

@interface ConnectServiceViewController ()<AuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectSpotifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectRdioLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectSoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectMsgLabel;

@property (weak, nonatomic) IBOutlet UISwitch *spotifySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *rdioSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;

@property (nonatomic, strong) UserAccount *userAccount;
@end

@implementation ConnectServiceViewController

#pragma mark -

- (UINavigationController *)authorizationNavVC{
    return [self.storyboard instantiateViewControllerWithIdentifier:@"AuthorizationNav"];
}

- (AuthorizationViewController *)authorizationVC{
    return [self.storyboard instantiateViewControllerWithIdentifier:@"AuthorizationVC"];
}

- (UserAccount *)userAccount{
    return [PTUtilities readLoginUser];
}

#pragma mark -

- (void)setupConnectView{
    self.title = PTNSLocalizedString(@"ConnectServiceTitleMsgKey", nil);
    
    self.connectSoundLabel.text = PTNSLocalizedString(@"SpotifyButtonMsgKey", nil);
    self.connectRdioLabel.text = PTNSLocalizedString(@"RdioButtonMsgKey", nil);
    self.connectSoundLabel.text = PTNSLocalizedString(@"SoundCloudButtonMsgKey", nil);
    self.connectMsgLabel.numberOfLines = 4;
    self.connectMsgLabel.text = PTNSLocalizedString(@"ConnectServiceDescMsgKey", nil);
    
    if (self.userAccount.spotifyAccount) {
        [self.spotifySwitch setOn:YES];
    }else{
        [self.spotifySwitch setOn:NO];
    }
    
    if (self.userAccount.rdioAccount) {
        [self.rdioSwitch setOn:YES];
    }else{
        [self.rdioSwitch setOn:NO];
    }
    
    if (self.userAccount.soundCloudAccount) {
        [self.soundSwitch setOn:YES];
    }else{
        [self.soundSwitch setOn:NO];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self setupConnectView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (void)pushAuthorizationVCWithConnectType:(ConnectService)type{
//    UINavigationController *authorizationNavVC = [self authorizationNavVC];
//    AuthorizationViewController *authorizationVC=[[authorizationNavVC viewControllers] firstObject];
    AuthorizationViewController *authorizationVC = [self authorizationVC];
    authorizationVC.delegate = self;
    authorizationVC.connectType = type;

//    [self presentViewController:authorizationNavVC animated:YES completion:nil];
    [self.navigationController pushViewController:authorizationVC animated:YES];
}

- (void)connectOutWithConnectService:(ConnectService)type{
    UserAccount *userAccount = [PTUtilities readLoginUser];

    switch (type) {
        case ConnectServiceSpotify:
            userAccount.spotifyAccount = nil;
            break;
        case ConnectServiceRdio:
            userAccount.rdioAccount = nil;
            break;
        default:
            userAccount.soundCloudAccount = nil;
            break;
    }
    [PTUtilities saveLoginUser:userAccount];
}

- (IBAction)spotifySwitchAction:(UISwitch *)sender {
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    if (sender.isOn) {
        [self pushAuthorizationVCWithConnectType:ConnectServiceSpotify];
    }else{
        [self connectOutWithConnectService:ConnectServiceSpotify];
    }
}

- (IBAction)rdioSwtichAction:(UISwitch *)sender {
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    if (sender.isOn) {
        [self pushAuthorizationVCWithConnectType:ConnectServiceRdio];
    }else{
        [self connectOutWithConnectService:ConnectServiceRdio];
    }
}

- (IBAction)soundSwitchAction:(UISwitch *)sender {
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    if (sender.isOn) {
        [self pushAuthorizationVCWithConnectType:ConnectServiceSoundCloud];
    }else{
        [self connectOutWithConnectService:ConnectServiceSoundCloud];
    }
}

#pragma mark - Authorization Delegate

- (void)authorizationDidfinished:(AuthorizationViewController *)controller success:(BOOL)status connectType:(ConnectService)type{
//    [controller dismissViewControllerAnimated:YES completion:nil];
    [controller.navigationController popViewControllerAnimated:YES];

//    if (!status) {
//        switch (type) {
//            case ConnectServiceRdio:
//                self.rdioSwitch.on = NO;
//                break;
//            case ConnectServiceSoundCloud:
//                self.soundSwitch.on = NO;
//                break;
//            default:
//                self.spotifySwitch.on = NO;
//                break;
//        }
//    }
    switch (type) {
        case ConnectServiceRdio:
            self.rdioSwitch.on = status;
            break;
        case ConnectServiceSoundCloud:
            self.soundSwitch.on = status;
            break;
        default:
            self.spotifySwitch.on = status;
            break;
    }
}
@end
