//
//  LoginPageContentViewController.m
//  Duorey
//
//  Created by xdy on 14/11/6.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ThirdpartyLoginViewController.h"
#import <TwitterKit/TwitterKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "EmailSignupViewController.h"
#import "FHSTwitterEngine.h"
#import "PTTheme.h"
#import "PTConstant.h"
#import "PTAppClientEngine.h"
#import <SVProgressHUD.h>
#import <UALogger.h>

#define kFloginCategory @"F_login"
#define kFloginEventClicklogin @"Click_login"

#define IS_IPHONE4 (([[UIScreen mainScreen] bounds].size.height<568)?YES:NO)
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height==568)?YES:NO)
#define IS_IPHONE6 (([[UIScreen mainScreen] bounds].size.height==667)?YES:NO)
#define IS_IPHONE6p (([[UIScreen mainScreen] bounds].size.height==736)?YES:NO)

@interface ThirdpartyLoginViewController ()<FHSTwitterEngineAccessTokenDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *frontLayerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backLayerImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *emailLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *tryButton;

@property (strong, nonatomic) NSArray *pageData;
@property (nonatomic, assign) NSInteger currentPageIndex;

@end

@implementation ThirdpartyLoginViewController

- (NSArray *)calculatePageData{
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 1; i<=4; i++) {
        if (IS_IPHONE4) {
            [temp addObject:[UIImage imageNamed:[NSString stringWithFormat:@"splash%d",i]]];
        }else if(IS_IPHONE5){
            [temp addObject:[UIImage imageNamed:[NSString stringWithFormat:@"splash%d-568h",i]]];
        }else if(IS_IPHONE6){
            [temp addObject:[UIImage imageNamed:[NSString stringWithFormat:@"splash%d-667h",i]]];
        }else{
            [temp addObject:[UIImage imageNamed:[NSString stringWithFormat:@"splash%d",i]]];
        }
    }
    
    return [temp copy];
}

- (NSArray *)pageData{
    if (!_pageData) {
        _pageData = [self calculatePageData];
    }
    
    return _pageData;
}

- (void)setupView{
    [self.scrollView setContentSize:CGSizeMake([self.pageData count] * CGRectGetWidth(self.view.frame), self.scrollView.contentSize.height)];
    
    [self.pageControl setNumberOfPages:[self.pageData count]];
    [self.pageControl setCurrentPage:0];
    [self.pageControl addTarget:self
                         action:@selector(pageControlValueDidChangeed:)
               forControlEvents:UIControlEventValueChanged];
    [self.facebookLoginButton setBackgroundImage:[[PTThemeManager sharedTheme] loginButtonBackgroundWithImage:@"fb"] forState:UIControlStateNormal];
    [self.facebookLoginButton setTitle:PTNSLocalizedString(@"FacebookButtonMsgKey", nil) forState:UIControlStateNormal];
    
    
    [self.twitterLoginButton setTitle:PTNSLocalizedString(@"TwitterButtonMsgKey", nil) forState:UIControlStateNormal];
    [self.twitterLoginButton setBackgroundImage:[[PTThemeManager sharedTheme] loginButtonBackgroundWithImage:@"twitter"] forState:UIControlStateNormal];
    
    
    [self.emailLoginButton setTitle:PTNSLocalizedString(@"EmailButoonMsgKey", nil) forState:UIControlStateNormal];
    [self.emailLoginButton setBackgroundImage:[[PTThemeManager sharedTheme] loginButtonBackgroundWithImage:@"email"] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setupView];
    [self setOriginLayersState];
    
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:TWITTER_CONSUMER_KEY andSecret:TWITTER_CONSUMER_SECRET];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginCategory action:@"in" label:@"login_in" value:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginCategory action:@"out" label:@"login_out" value:nil];
}

#pragma mark - layers management

- (void)setBackLayerPictureWithPageIndex:(NSInteger)index {
    [self setBackgroundImage:self.backLayerImageView withIndex:index + 1];
}

- (void)setFrontLayerPictureWithPageIndex:(NSInteger)index {
    [self setBackgroundImage:self.frontLayerImageView withIndex:index];
}

- (void)setBackgroundImage:(UIImageView *)imageView withIndex:(NSInteger)index {
    if (index >= [self.pageData count]) {
        [imageView setImage:nil];
        return;
    }
    
    [imageView setImage:self.pageData[index]];
}

- (void)setOriginLayerAlpha {
    [self.frontLayerImageView setAlpha:1];
    [self.backLayerImageView setAlpha:0];
}

- (void)setOriginLayersState{
    [self.backLayerImageView setBackgroundColor:[UIColor blackColor]];
    [self.frontLayerImageView setBackgroundColor:[UIColor blackColor]];
    [self setLayersPicturesWithIndex:0];
}

- (void)setLayersPicturesWithIndex:(NSInteger)index {
    self.currentPageIndex = index;
    [self setOriginLayerAlpha];
    [self setFrontLayerPictureWithPageIndex:index];
    [self setBackLayerPictureWithPageIndex:index];
}

- (void)scrollingToNextPageWithOffset:(float)offset {
    NSInteger nextPage = (int)offset;
    
    float alphaValue = offset - nextPage;
    
    if (alphaValue < 0 && self.currentPageIndex == 0){
        [self.backLayerImageView setImage:nil];
        [self.frontLayerImageView setAlpha:(1 + alphaValue)];
        return;
    }

    if (nextPage != self.currentPageIndex ||
        ((nextPage == self.currentPageIndex) && (0.0 < offset) && (offset < 1.0)))
        [self setLayersPicturesWithIndex:nextPage];
    
    float backLayerAlpha = alphaValue;
    float frontLayerAlpha = (1 - alphaValue);

    [self.backLayerImageView setAlpha:backLayerAlpha];
    [self.frontLayerImageView setAlpha:frontLayerAlpha];
}

#pragma mark - FHSTwitterEngine delegate

- (void)storeAccessToken:(NSString *)accessToken {
//    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
    SET_DEFAULTS(Object, @"SavedAccessHTTPBody", accessToken);
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark - Action

- (IBAction)pageControlValueDidChangeed:(UIPageControl *)sender{
    [self.scrollView setContentOffset:CGPointMake(sender.currentPage * CGRectGetWidth(self.view.frame),0)
                             animated:YES];
}

- (IBAction)loginWithTwitterAction:(id)sender {
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginCategory action:kFloginEventClicklogin label:@"twitter" value:nil];
    __block ThirdpartyLoginViewController *weakSelf = self;
//#warning "需要去掉授权的登录信息"
//    if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
//        NSDictionary *result = DEFAULTS(object, @"twitter");
//        [SVProgressHUD showWithStatus:PTNSLocalizedString(@"Login...", nil) maskType:SVProgressHUDMaskTypeBlack];
//        [[PTAppClientEngine sharedClient] thirdpartyLoginDuoreySystemWithUserId:[result objectForKey:@"userid"]
//                                                                       nickname:[result objectForKey:@"name"]
//                                                                 pImageLargeURL:[result objectForKey:@"profileImageUrl"]
//                                                                       userType:UserTypeTwitter
//                                                                     completion:^(UserAccount *user, NSError *error) {
//                                                                         if (user) {
//                                                                             if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
//                                                                                 [self.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:user];
//                                                                             }
//                                                                             postNotification(DuoreyDidLoginNotification, user, nil);
//                                                                             [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"login success", nil)];
//                                                                         }else{
//                                                                             [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
//                                                                         }
//                                                                     }];
//    }else{
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success) {
        if (success) {
            [SVProgressHUD showWithStatus:PTNSLocalizedString(@"LoginLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                id result = [[FHSTwitterEngine sharedEngine] getUserShowForUsername:[[FHSTwitterEngine sharedEngine] authenticatedID] isID:YES];
                UALog(@"twitter login resut: %@", result);
//                    id result = DEFAULTS(object, @"twitter");
                if ([result isKindOfClass:[NSError class]]) {
                    [SVProgressHUD showErrorWithStatus:[result localizedDescription]];
                }else{
//                    SET_DEFAULTS(Object, @"twitter", result);
                    [[PTAppClientEngine sharedClient] thirdpartyLoginDuoreySystemWithUserId:[result objectForKey:@"userid"]
                                                                                   nickname:[result objectForKey:@"name"]
                                                                             pImageLargeURL:[result objectForKey:@"profileImageUrl"]
                                                                                   userType:UserTypeTwitter
                                                                                 completion:^(UserAccount *user, NSError *error) {
                                                                                     if (user) {
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             if ([weakSelf.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
                                                                                                 [weakSelf.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:user];
                                                                                             }
                                                                                             postNotification(DuoreyDidLoginNotification, user, nil);
                                                                                             [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"LoginOKMsgKey", nil)];
                                                                                         });
                                                                                     }else{
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                                         });
                                                                                     }
                                                                                 }];
                    
                }
            });
        }else{
            [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"TwitterAuthorizeErrorMsgKey", nil)];
        }
    }];
    loginController.title = PTNSLocalizedString(@"TwitterLoginTitleMsgKey", nil);
    [self.navigationController pushViewController:loginController animated:YES];
//    [self presentViewController:loginController animated:YES completion:nil];
//    }
    
//    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"Login...", nil) maskType:SVProgressHUDMaskTypeBlack];
//    __block ThirdpartyLoginViewController *weakSelf = self;
//    
//    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
//        if (session) {
//            [[[Twitter sharedInstance] APIClient] loadUserWithID:session.userID completion:^(TWTRUser *user, NSError *error) {
//                if (error) {
//                    if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
//                        [self.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:nil];
//                    }
//                    [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"Twitter授权失败", nil)];
//                }else{
//                    [[PTAppClientEngine sharedClient] thirdpartyLoginDuoreySystemWithUserId:user.userID
//                                                                                   nickname:user.screenName
//                                                                             pImageLargeURL:user.profileImageLargeURL
//                                                                                   userType:UserTypeTwitter
//                                                                                 completion:^(User *user, NSError *error) {
//                                                                                     if (user) {
//                                                                                         if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
//                                                                                             [self.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:user];
//                                                                                         }
//                                                                                         [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"login success", nil)];
//                                                                                     }else{
//                                                                                         if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
//                                                                                             [self.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:nil];
//                                                                                         }
//                                                                                         [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"message"]];
//                                                                                     }
//                                                                                 }];
//                }
//            }];
//        }else{
//            if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
//                [self.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:nil];
//            }
//            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
//        }
//    }];
}

- (IBAction)loginWithFacebookAction:(id)sender {
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginCategory action:kFloginEventClicklogin label:@"facebook" value:nil];
    __block ThirdpartyLoginViewController *weakSelf = self;
//    if (true) {
//        [SVProgressHUD showWithStatus:PTNSLocalizedString(@"Login...", nil) maskType:SVProgressHUDMaskTypeBlack];
//        id result = DEFAULTS(object, @"Facebook");
//        [[PTAppClientEngine sharedClient] thirdpartyLoginDuoreySystemWithUserId:[result objectForKey:@"user_ext_id"]
//                                                                       nickname:[result objectForKey:@"nick_name"]
//                                                                 pImageLargeURL:[result objectForKey:@"user_ico"]
//                                                                       userType:UserTypeFacebook
//                                                                     completion:^(UserAccount *user, NSError *error) {
//                                                                         if (user) {
//                                                                             if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
//                                                                                 [self.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:user];
//                                                                             }
//                                                                             postNotification(DuoreyDidLoginNotification, user, nil);
//                                                                             [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"login success", nil)];
//                                                                         }else{
//                                                                             [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
//                                                                         }
//                                                                     }];
//    }else{
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         if (!error && (state == FBSessionStateOpen)){
             [SVProgressHUD showWithStatus:PTNSLocalizedString(@"LoginLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
             [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 UALog(@"result...%@",result);
                 if (error) {
                     [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"FacebookAuthorizeErrorMsgKey", nil)];
                 }else{
                     [[PTAppClientEngine sharedClient] thirdpartyLoginDuoreySystemWithUserId:[result objectForKey:@"id"]
                                                                                    nickname:[result objectForKey:@"name"]
                                                                              pImageLargeURL:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[result objectForKey:@"id"]]
                                                                                    userType:UserTypeFacebook
                                                                                  completion:^(UserAccount *user, NSError *error) {
                                                                                      if (user) {
                                                                                          if ([weakSelf.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
                                                                                              [weakSelf.delegate thirdpartyLoginViewController:weakSelf didLoginSuccess:user];
                                                                                          }
                                                                                          postNotification(DuoreyDidLoginNotification, user, nil);
                                                                                          [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"LoginOKMsgKey", nil)];
                                                                                      }else{
                                                                                          [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                                      }
                                                                                  }];
                 }
             }];
         }else{
             [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"FacebookAuthorizeErrorMsgKey", nil)];
         }
     }];
//    }
}

- (IBAction)tryUseAppButtonAction:(id)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginCategory action:@"Click_try" label:@"try" value:nil];
    UserAccount *user = [[UserAccount alloc] init];
    user.tryUseApp = YES;
    [PTUtilities saveLoginUser:user];
    if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
        [self.delegate thirdpartyLoginViewController:self didLoginSuccess:user];
    }
    postNotification(DuoreyDidLoginNotification, user, nil);
}

#pragma mark - EmailLoginDelegate
- (void)emailLoginViewController:(EmailSignupViewController *)viewController didSuccess:(UserAccount *)user{
    [viewController.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(thirdpartyLoginViewController:didLoginSuccess:)]) {
        [self.delegate thirdpartyLoginViewController:self didLoginSuccess:user];
    }
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float scrollingPosition = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    
    [self scrollingToNextPageWithOffset:scrollingPosition];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.pageControl setCurrentPage:self.currentPageIndex];
}

#pragma mark - push
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"pushEmailLogin"]) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginCategory action:kFloginEventClicklogin label:@"email" value:nil];
        [self.navigationController.navigationBar setHidden:NO];
//        EmailSignupViewController *emailLoginVC = segue.destinationViewController;
//        emailLoginVC.delegate = self;
    }
}

@end
