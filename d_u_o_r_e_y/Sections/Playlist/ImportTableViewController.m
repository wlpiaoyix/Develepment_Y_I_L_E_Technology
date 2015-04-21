//
//  ImportTableViewController.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ImportTableViewController.h"
#import "PTAppClientEngine.h"
#import "PTUtilities.h"
#import "SongObj.h"
#import "AuthorizationViewController.h"
#import "PTEnum.h"

@interface ImportTableViewController ()<UIAlertViewDelegate,AuthorizationViewControllerDelegate>

@end

@implementation ImportTableViewController

- (AuthorizationViewController *)authorizationVC{
    return [self.storyboard instantiateViewControllerWithIdentifier:@"AuthorizationVC"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentidier = @"ImportCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentidier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentidier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row==0) {
        [cell.imageView setImage:[UIImage imageNamed:@"cellConnectSoundCloud"]];
        [cell.textLabel setText:PTNSLocalizedString(@"SoundCloudButtonMsgKey", nil)];
    }else if (indexPath.row==1){
        [cell.imageView setImage:[UIImage imageNamed:@"cellConnectSpotify"]];
        [cell.textLabel setText:PTNSLocalizedString(@"SportifyButtonMsgKey", nil)];
    }else{
        [cell.imageView setImage:[UIImage imageNamed:@"cellConnectRdio"]];
        [cell.textLabel setText:PTNSLocalizedString(@"RdioButtonMsgKey", nil)];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInsection:(NSIndexPath *)indexPath{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [aView setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]];
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [aLabel setText:PTNSLocalizedString(@"ImportDescMsgKey", nil)];
    [aLabel setTextColor:[UIColor colorWithWhite:0.502 alpha:1.000]];
    [aLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [aLabel setTextAlignment:NSTextAlignmentCenter];
    [aView addSubview:aLabel];
    return aView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserAccount *user = [PTUtilities readLoginUser];
    if (user.soundCloudAccount.accessToken==nil) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:PTNSLocalizedString(@"SoundCloudAuthorizationPromptTitleMsgKey", nil)
                                                        message:PTNSLocalizedString(@"SoundCloudAuthorizationPromptMsgKey", nil)
                                                       delegate:self
                                              cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil)
                                              otherButtonTitles:PTNSLocalizedString(@"AuthorizeButtonMsgKey", nil), nil];
        [alter show];
        return;
    }
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_add_import" action:@"Click_import" label:@"Souncloud" value:nil];
    NSString *imported = [PTUtilities unarchiveObjectWithName:[NSString stringWithFormat:@"isImported_%@",user.userId]];
    NSTimeInterval newTime = [[NSDate date] timeIntervalSince1970];
    if(![PTUtilities isEmptyOrNull:imported] && [imported intValue]>0){
        int time = newTime;
        int seTime = time - [imported intValue];
        if (seTime <= 600) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:PTNSLocalizedString(@"ImportTimeShortMsgKey", nil),600-seTime]];
            return;
        }
    }
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"ImportLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
    SongObj *song = [[SongObj alloc] init];
    [song getSoundCloudUserPlaylistCompletion:^(ImportPlaylist *importPlaylist,NSError *error){
        if (!error) {
            UALog(@"---%@",[MTLJSONAdapter JSONDictionaryFromModel:importPlaylist]);
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            NSString *str = [PTUtilities dictionaryToJson:(NSMutableDictionary *)[MTLJSONAdapter JSONDictionaryFromModel:importPlaylist]];
            [dic setObject:str forKey:@"data"];
            [dic setObject:user.userId forKey:@"uid"];
            [dic setObject:user.userToken forKey:@"token"];
            #if defined(__LP64__) && __LP64__
            [dic setObject:[NSString stringWithFormat:@"%lu",(unsigned long)MusicSourceSoundCloud] forKey:@"category"];
            #else
            [dic setObject:[NSString stringWithFormat:@"%d",MusicSourceSoundCloud] forKey:@"category"];
            #endif
            [[PTAppClientEngine sharedClient] importPlatlistWithDic:dic completion:^(NSError *error){
                if(!error){
                    [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"ImportPlaylistOkMsgKey", nil)];
                    [PTUtilities archiveObject:[NSString stringWithFormat:@"%d",(int)newTime]
                                      withName:[NSString stringWithFormat:@"isImported_%@",user.userId]];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}


#pragma mark - uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        AuthorizationViewController *authorizationVC = [self authorizationVC];
        authorizationVC.delegate = self;
        authorizationVC.connectType = 3;
        [self.navigationController pushViewController:authorizationVC animated:YES];
    }
}

#pragma mark - Authorization Delegate

- (void)authorizationDidfinished:(AuthorizationViewController *)controller success:(BOOL)status connectType:(ConnectService)type{
    [controller.navigationController popViewControllerAnimated:YES];
}
@end
