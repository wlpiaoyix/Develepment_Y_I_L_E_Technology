//
//  NewPlaylistSetNameViewController.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "NewPlaylistSetNameViewController.h"
#import "PlaylistSearchViewController.h"
#import <SVProgressHUD.h>
#import "PTAppClientEngine.h"
#import "PTDefinitions.h"
#import "PTConstant.h"

@interface NewPlaylistSetNameViewController ()<PlaylistSearchViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation NewPlaylistSetNameViewController
@synthesize delegate=delegate;

- (UserAccount *)userAccount{
    return [PTUtilities readLoginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    // Do any additional setup after loading the view.
//    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    self.title = PTNSLocalizedString(@"NewPlaylistTitleMsgKey", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return (int)[da length];
}



- (IBAction)doneButtonAction:(id)sender {
    NSString *nameStr = _nameTextField.text;
    if ([PTUtilities isEmptyOrNull:nameStr] || [self getToInt:nameStr]>30) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"PlaylistNameIllegalMsgKey", nil)];
        return;
    }
    UserAccount *user = [self userAccount];
    if (_nameTextField.text && [_nameTextField.text length]>0) {
        [SVProgressHUD showWithStatus:PTNSLocalizedString(@"CreatePlaylistLoadingMsgKey", nil)
                             maskType:SVProgressHUDMaskTypeBlack];
        if (![self.whereF isEqualToString:@"searchMusic"]) {
            __block NewPlaylistSetNameViewController *weakSelf = self;
            [[PTAppClientEngine sharedClient] creatPlaylistWithPlaylistName:self.nameTextField.text
                                                                     userId:[NSString stringWithFormat:@"%@",user.userId]
                                                                      token:user.userToken
                                                                 completion:^(NSString* listId, NSError *error) {
                if (!error) {
                    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_add" action:@"Click_new" label:@"done" value:nil];
                    [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"CreatePlylistOkMsgKey", nil)];
                    PlaylistSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistSearchVC"];
                    searchVC.whereF=listId;
                    searchVC.delegate=self;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
                    [weakSelf presentViewController:nav animated:YES completion:nil];
                }else{
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
            }];
        }else{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            NSString *str = [PTUtilities dictionaryToJson:self.musicDic];
            [dic setObject:str forKeyedSubscript:@"data"];
            [dic setObject:self.nameTextField.text forKey:@"list_name"];
            [dic setObject:[NSString stringWithFormat:@"%@",user.userId] forKey:@"uid"];
            [dic setObject:user.userToken forKey:@"token"];
            [[PTAppClientEngine sharedClient] addOneMusicToCreatListWithMusicDic:dic
                                                                      completion:^(NSError *error) {
                                                                          if (error==nil) {
                                                                              [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"CreatePlylistOkMsgKey", nil)];
                                                                              [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_add" action:@"Click_new" label:@"done" value:nil];
                                                                              [self.navigationController popViewControllerAnimated:YES];
                                                                              if ([self.delegate respondsToSelector:@selector(doDismissView)]) {
                                                                                  [self.delegate doDismissView];
                                                                              }
                                                                          }else{
                                                                              [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                          }
                                                                      }];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"PlaylistNameIllegalMsgKey", nil)];
    }
}

- (void)creatPlaylistBack{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
@end
