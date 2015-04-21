//
//  SettingViewController.m
//  Duorey
//
//  Created by xdy on 14/11/20.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "SettingViewController.h"
#import "PTDefinitions.h"
#import "PTUtilities.h"
#import <UALogger.h>
#import "PTConstant.h"
#import <CTFeedback/CTFeedbackViewController.h>
#import <UAAppReviewManager.h>
#import "AppDelegate.h"
#import "UserAccount.h"
#import "UIViewController+Balancer.h"
#import "YLAudioPlayer.h"
#import <TwitterKit/TwitterKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FHSTwitterEngine.h"

@interface SettingViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *networkLabel;
@property (weak, nonatomic) IBOutlet UISwitch *networkSwitch;
@property (weak, nonatomic) IBOutlet UILabel *inviteFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailSupportLabel;
@property (weak, nonatomic) IBOutlet UILabel *appStoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;


@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"in" label:@"S_set_in" value:nil];

    [self setUpBalancerView];
    
    self.title = PTNSLocalizedString(@"SettingTitleMsgKey", nil);
    self.networkSwitch.on = DEFAULTS(bool, NO_WIFI_PLAY_SETTING);
    self.networkLabel.text = PTNSLocalizedString(@"SettingNoWifiPlayMsgKey", nil);
    self.inviteFriendsLabel.text = PTNSLocalizedString(@"SettingInviteFriendsMsgKey", nil);
    self.emailSupportLabel.text = PTNSLocalizedString(@"SettingEmailSupportMsgKey", nil);
    self.appStoreLabel.text = PTNSLocalizedString(@"SettingLoveUsMsgKey", nil);
    self.aboutLabel.text = PTNSLocalizedString(@"SettingAboutMsgKey", nil);
    self.logoutLabel.text = PTNSLocalizedString(@"SettingLogoutMsgKey", nil);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"out" label:@"S_set_out" value:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle = nil;
    switch (section) {
        case 0:
            sectionTitle = PTNSLocalizedString(@"NetWorkSectionTitleMsgKey", nil);
            break;
        case 1:
            sectionTitle = PTNSLocalizedString(@"FriendsSectionTitleMsgKey", nil);
            break;
        case 2:
            sectionTitle = PTNSLocalizedString(@"FeedbackSectionTitleMsgKey", nil);
            break;
        case 3:
            sectionTitle = PTNSLocalizedString(@"InformationSectionTitleMsgKey", nil);
            break;
        default:
            sectionTitle = PTNSLocalizedString(@"LogoutSectionTitleMsgKey", nil);
            break;
    }
    
    return sectionTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UALog(@"click cell section...%d....row....%d",(int)indexPath.section,(int)indexPath.row);
    switch (indexPath.section) {
        case 0://network
            [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"Click_s_set" label:@"network" value:nil];
            break;
        case 1://friends
        {
            [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"Click_s_set" label:@"friend" value:nil];
            __weak SettingViewController *weakSelf = self;
//            UIImage *imageToShare = [UIImage imageNamed:@"CD-Cover"];
            NSURL *urlToShare = [NSURL URLWithString:APP_ITUNES_DOWNLOAD_URL_KEY];
            NSString *msgToShare = PTNSLocalizedString(@"ShareContentMsgKey", nil);
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[msgToShare,urlToShare] applicationActivities:nil];
            activityView.excludedActivityTypes = @[UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList];
            activityView.completionHandler = ^(NSString *activityType, BOOL completed){
                SettingViewController *strongSelf = weakSelf;
                [strongSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
                UALog(@"ActivityType: %@",activityType);
                if (completed) {
                    UALog(@"complete");
                }else{
                    UALog(@"cancel");
                }
            };
            [self presentViewController:activityView animated:YES completion:nil];
        }
            break;
        case 2://feedback
        {
            if (indexPath.row == 0) {
                //email
                [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"Click_s_set" label:@"email" value:nil];
                CTFeedbackViewController *feedbackViewController = [CTFeedbackViewController controllerWithTopics:CTFeedbackViewController.defaultTopics localizedTopics:CTFeedbackViewController.defaultLocalizedTopics];
                feedbackViewController.toRecipients = @[PHONTUNES_EMAIL];
                feedbackViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:feedbackViewController animated:YES];
            }else{
                //appstore
                [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"Click_s_set" label:@"rate" value:nil];
                [UAAppReviewManager rateApp];
            }
        }
            break;
        case 3://about
            [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"Click_s_set" label:@"about" value:nil];
            break;
        default://logout
        {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:PTNSLocalizedString(@"LogoutPromptMsgKey", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:PTNSLocalizedString(@"OKButtonMsgKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"Click_s_set" label:@"logout" value:nil];
                [PTUtilities saveLoginUser:nil];
                [[YLAudioPlayer sharedAudioPlayer] stopPlay];
                postNotification(STOP_BALANCER_ANIMATION, nil, nil);
                [((AppDelegate *)[UIApplication sharedApplication].delegate) showIntroductionView];
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:cancel];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
#else
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:PTNSLocalizedString(@"LogoutPromptMsgKey", nil)
                                                               delegate:self
                                                      cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil)
                                                      otherButtonTitles:PTNSLocalizedString(@"OKButtonMsgKey", nil), nil];
            [alertView show];
#endif
        }
            break;
    }
}

#pragma mark - Action

- (IBAction)networkSwitchAction:(UISwitch *)sender {
    SET_DEFAULTS(Bool, NO_WIFI_PLAY_SETTING, sender.isOn);
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_set" action:@"Click_s_set" label:@"logout" value:nil];
        [PTUtilities saveLoginUser:nil];
        [[YLAudioPlayer sharedAudioPlayer] stopPlay];
        [FBSession.activeSession closeAndClearTokenInformation];
        [[FHSTwitterEngine sharedEngine] clearAccessToken];
        [[FHSTwitterEngine sharedEngine] clearConsumer];
        postNotification(STOP_BALANCER_ANIMATION, nil, nil);
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showIntroductionView];
    }
}
@end
