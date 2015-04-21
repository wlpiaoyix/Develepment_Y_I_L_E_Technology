//
//  AuthorizationViewController.m
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "AuthorizationViewController.h"
#import <Rdio/Rdio.h>
#import "UserAccount.h"
#import <Mantle.h>
#import "PTUtilities.h"
#import <AFNetworking.h>
#import <UALogger.h>
#import "NSString+Hash.h"
#import <SCAPI.h>
#import <SCUI.h>
#import <NXOAuth2.h>


static NSString * const YL_OAUTH_ERROR_DOMAIN    = @"com.yile.oauth.domain.error";

@interface AuthorizationViewController ()<UIWebViewDelegate,RdioDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) Rdio *rdio;
@property (strong, nonatomic) NSURLSessionDataTask *httpOperation;
@end

@implementation AuthorizationViewController

@synthesize rdio = _rdio;

+ (void)refreshSpotifyTokenWithRefreshToken:(UserAccount *)userAccount completion:(void(^)(UserAccount *user,NSError *error))block{
    NSString * baseUrlStr=@"https://accounts.spotify.com/api/token";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"refresh_token" forKey:@"grant_type"];
    [dic setObject:userAccount.spotifyAccount.refreshToken forKey:@"refresh_token"];
    
    AFHTTPSessionManager *httpClient = [AFHTTPSessionManager manager];
    
    [httpClient.requestSerializer setAuthorizationHeaderFieldWithUsername:SPOTIFY_KEY password:SPOTIFY_SECRET];
    [httpClient POST:baseUrlStr parameters:dic success:^(NSURLSessionDataTask *task, id responseObject){
        UserAccount *userAccount = [PTUtilities readLoginUser];
        userAccount.spotifyAccount.accessToken = [responseObject objectForKey:@"access_token"];
        userAccount.spotifyAccount.expiresIn = [responseObject objectForKey:@"expires_in"];
        userAccount.spotifyAccount.tokenType = [responseObject objectForKey:@"token_type"];
        userAccount.spotifyAccount.expiresDate = [NSDate dateWithTimeInterval:[[responseObject objectForKey:@"expires_in"] floatValue] sinceDate:[NSDate date]];
        [PTUtilities saveLoginUser:userAccount];
        
        if (block) {
            block(userAccount,nil);
        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        UALog(@"Error: %@",error);
        if (block) {
            block(nil,[NSError errorWithDomain:YL_OAUTH_ERROR_DOMAIN code:1002 userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"SpotifyRefreshTokenErrorMsgKey", nil)}]);
        }
    }];
}

- (Rdio *)rdio{
    if (!_rdio) {
        _rdio = [[Rdio alloc] initWithConsumerKey:RDIO_KEY andSecret:RDIO_SECRET delegate:self];
    }
    return _rdio;
}

- (void)authorizationSpotify{
    self.title = PTNSLocalizedString(@"SpotifyAuthorizationTitleMsgKey", nil);
    [self authorizationWebViewWithURL:[self spotifyTorken]];
}

- (void)authorizationRdio{
    self.title = PTNSLocalizedString(@"RdioAuthorizationTitleMsgKey", nil);
    [self.rdio authorizeFromController:self];
}


- (void)authorizationSoundCloud{
    self.title = PTNSLocalizedString(@"SoundCloudAuthorizationTitleMsgKey", nil);
//    [self authorizationWebViewWithURL:[self soundCloudTorken]];
    __block AuthorizationViewController *weakSelf = self;
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            UALog(@"Canceled!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf cancel];
                if ([weakSelf.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
                    [weakSelf.delegate authorizationDidfinished:weakSelf success:NO connectType:self.connectType];
                }
            });
        } else if (error) {
            UALog(@"Error: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                if ([weakSelf.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
                    [weakSelf.delegate authorizationDidfinished:weakSelf success:NO connectType:self.connectType];
                }
            });
        } else {
            UALog(@"Done!");
            UserAccount *userAccount = [PTUtilities readLoginUser];
            SoundCloudAccount *soundCloudAccount = [[SoundCloudAccount alloc] init];
            soundCloudAccount.soundCloudKey = SOUNDCLOUD_KEY;
            soundCloudAccount.soundCloudSecret = SOUNDCLOUD_SECRET;
            NXOAuth2Account *oauth2 = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:[SCSoundCloud account].identifier];
            soundCloudAccount.accessToken = oauth2.accessToken.accessToken;
            userAccount.soundCloudAccount = soundCloudAccount;
            [PTUtilities saveLoginUser:userAccount];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"AuthorizationOkMsgKey", nil)];
                if ([weakSelf.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
                    [weakSelf.delegate authorizationDidfinished:weakSelf success:YES connectType:self.connectType];
                }
            });
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (void)authorizationWebViewWithURL:(NSURL *)url{
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    [self.webView loadRequest:mRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
//    self.webView.scrollView.scrollEnabled = NO;
//    self.webView.scrollView.bounces = NO;
    UALog(@"connectType..%d",(int)self.connectType);
    
    switch (self.connectType) {
        case ConnectServiceRdio:
            [self authorizationRdio];
            break;
        case ConnectServiceSoundCloud:
            [self authorizationSoundCloud];
            break;
        default:
            [self authorizationSpotify];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self cancel];
}

#pragma mark get authorize

static NSString * const AFAppDoSoundCloudBaseUrlString = @"https://soundcloud.com/connect?client_id=%@&response_type=code&scope=non-expiring&display=popup&redirect_uri=%@";
static NSString * const AFAppDoSpotifyBaseUrlString = @"https://accounts.spotify.com/authorize?client_id=%@&response_type=code&redirect_uri=%@&scope=user-read-private";

- (NSURL *)soundCloudTorken{
    NSString *urlString = [NSString stringWithFormat:AFAppDoSoundCloudBaseUrlString,SOUNDCLOUD_KEY,SOUNDCLOUD_CALLBACK_URL];
//    return [NSURL URLWithString:[urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)spotifyTorken{
    NSString *urlString = [NSString stringWithFormat:AFAppDoSpotifyBaseUrlString,SPOTIFY_KEY,SPOTIFY_CALLBACK_URL];
//    return [NSURL URLWithString:[urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [NSURL URLWithString:urlString];
}

#pragma mark web view call back

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [SVProgressHUD show];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UALog(@"webView...%@",error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (request.URL!=nil) {
        NSString *str = [NSString stringWithFormat:@"%@",request.URL];
//        if ([str hasPrefix:@"http://www.google.com/?code="]) {
//            NSRange range = [str rangeOfString:@"="];
//            NSString *torkenStr = [str substringFromIndex:range.location+1];
//            NSString *baseUrlStr=nil;
//            switch (self.connectType) {
//                case ConnectServiceSpotify:{
//                    baseUrlStr=@"https://accounts.spotify.com/api/token";
//                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//                    [dic setObject:torkenStr forKey:@"code"];
//                    [dic setObject:@"authorization_code" forKey:@"grant_type"];
//                    [dic setObject:SPOTIFY_KEY forKey:@"client_id"];
//                    [dic setObject:SPOTIFY_SECRET forKey:@"client_secret"];
//                    [dic setObject:CALL_BACK_URL forKey:@"redirect_uri"];
//                    [self getTorkenStrWtihUrl:baseUrlStr
//                                    parmaters:dic
//                                     platform:ConnectServiceSpotify];
//                }
//                    break;
//                case ConnectServiceSoundCloud:{
//                    baseUrlStr=@"https://api.soundcloud.com/oauth2/token?";
//                    NSString *aTorkenStr = [torkenStr substringToIndex:[torkenStr length]-1];
//                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//                    [dic setObject:SOUNDCLOUD_KEY forKey:@"client_id"];
//                    [dic setObject:SOUNDCLOUD_SECRET forKey:@"client_secret"];
//                    [dic setObject:@"authorization_code" forKey:@"grant_type"];
//                    [dic setObject:CALL_BACK_URL forKey:@"redirect_uri"];
//                    [dic setObject:aTorkenStr forKey:@"code"];
//                    [self getTorkenStrWtihUrl:baseUrlStr
//                                    parmaters:dic
//                                     platform:ConnectServiceSoundCloud];
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
        
        if ([str hasPrefix:[NSString stringWithFormat:@"%@?code=",SPOTIFY_CALLBACK_URL]] || [str hasPrefix:[NSString stringWithFormat:@"%@?code=",SOUNDCLOUD_CALLBACK_URL]]) {
            NSRange range = [str rangeOfString:@"="];
            NSString *torkenStr = [str substringFromIndex:range.location+1];
            NSString *baseUrlStr=nil;
            switch (self.connectType) {
                case ConnectServiceSpotify:{
                    baseUrlStr=@"https://accounts.spotify.com/api/token";
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:torkenStr forKey:@"code"];
                    [dic setObject:@"authorization_code" forKey:@"grant_type"];
                    [dic setObject:SPOTIFY_KEY forKey:@"client_id"];
                    [dic setObject:SPOTIFY_SECRET forKey:@"client_secret"];
                    [dic setObject:SPOTIFY_CALLBACK_URL forKey:@"redirect_uri"];
                    [self getTorkenStrWtihUrl:baseUrlStr
                                    parmaters:dic
                                     platform:ConnectServiceSpotify];
                }
                    break;
                case ConnectServiceSoundCloud:{
                    baseUrlStr=@"https://api.soundcloud.com/oauth2/token?";
                    NSString *aTorkenStr = [torkenStr substringToIndex:[torkenStr length]-1];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:SOUNDCLOUD_KEY forKey:@"client_id"];
                    [dic setObject:SOUNDCLOUD_SECRET forKey:@"client_secret"];
                    [dic setObject:@"authorization_code" forKey:@"grant_type"];
                    [dic setObject:SOUNDCLOUD_CALLBACK_URL forKey:@"redirect_uri"];
                    [dic setObject:aTorkenStr forKey:@"code"];
                    [self getTorkenStrWtihUrl:baseUrlStr
                                    parmaters:dic
                                     platform:ConnectServiceSoundCloud];
                }
                    break;
                default:
                    break;
            }
        }
    }
    return YES;
}

- (void)getTorkenStrWtihUrl:(NSString *)urlStr
                  parmaters:(NSMutableDictionary *)dic
                   platform:(ConnectService)connectType{
    [self.webView stopLoading];
    __block AuthorizationViewController *weakSelf = self;
    __block AFHTTPSessionManager *httpClient = [AFHTTPSessionManager manager];
    if (self.httpOperation) {
        [self.httpOperation cancel];
    }
    self.httpOperation = [httpClient POST:urlStr parameters:dic success:^(NSURLSessionDataTask *task, id responseObject){
        UserAccount *userAccount = [PTUtilities readLoginUser];
        if (ConnectServiceSpotify == connectType) {
            SpotifyAccount *spotifyAccount = [MTLJSONAdapter modelOfClass:SpotifyAccount.class fromJSONDictionary:responseObject error:nil];
            spotifyAccount.spotifyKey = SPOTIFY_KEY;
            spotifyAccount.spotifySecret = SPOTIFY_SECRET;
            spotifyAccount.expiresDate = [NSDate dateWithTimeInterval:[spotifyAccount.expiresIn floatValue] sinceDate:[NSDate date]];
            
            AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
            
            [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",spotifyAccount.accessToken] forHTTPHeaderField:@"Authorization"];
            [httpClient setRequestSerializer:requestSerializer];
            [httpClient GET:@"https://api.spotify.com/v1/me" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//                UALog(@"spotify..user..%@",responseObject);
//                {country = US;
//                "display_name" = "Ying  Xu";
//                email = "zhiluna6622@163.com";
//                "external_urls" =     {
//                    spotify = "https://open.spotify.com/user/zhiluna6622";
//                };
//                followers =     {
//                    href = "<null>";
//                    total = 0;
//                };
//                href = "https://api.spotify.com/v1/users/zhiluna6622";
//                id = zhiluna6622;
//                images =     (
//                              {
//                                  height = "<null>";
//                                  url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xap1/v/t1.0-1/s200x200/29373_100126453483000_1182818639_n.jpg?oh=3734f7ab9598d17ce072b145f704ebc9&oe=54D7B9D9&__gda__=1423766631_7cc875887f3bf90fc73fc9b0e4b2b293";
//                                  width = "<null>";
//                              }
//                              );
//                product = premium;
//                type = user;
//                uri = "spotify:user:zhiluna6622";}
                spotifyAccount.userName = [responseObject objectForKey:@"id"];
                spotifyAccount.product = [responseObject objectForKey:@"product"];
                userAccount.spotifyAccount = spotifyAccount;
                [PTUtilities saveLoginUser:userAccount];
                [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"AuthorizationOkMsgKey", nil)];
                if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
                    [self.delegate authorizationDidfinished:weakSelf success:YES connectType:self.connectType];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                //
                UALog(@"spotify..user..error..%@",error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
                    [self.delegate authorizationDidfinished:weakSelf success:NO connectType:self.connectType];
                }
            }];
        }else{
            SoundCloudAccount *soundCloudAccount = [MTLJSONAdapter modelOfClass:SoundCloudAccount.class fromJSONDictionary:responseObject error:nil];
            soundCloudAccount.soundCloudKey = SOUNDCLOUD_KEY;
            soundCloudAccount.soundCloudSecret = SOUNDCLOUD_SECRET;
            userAccount.soundCloudAccount = soundCloudAccount;
            [PTUtilities saveLoginUser:userAccount];
            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"AuthorizationOkMsgKey", nil)];
            if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
                [self.delegate authorizationDidfinished:weakSelf success:YES connectType:self.connectType];
            }
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        UALog(@"Error: %@",error);
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
            [self.delegate authorizationDidfinished:weakSelf success:NO connectType:self.connectType];
        }
    }];
}

#pragma mark - Rdio delegate

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken{
    UALog(@"accessToken:%@",accessToken);
    NSArray *accArr = [accessToken componentsSeparatedByString:@"&"];
    
    NSDictionary *JSONDictionary = @{
                                     @"accessToken": [[[accArr objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1],
                                     @"accessTokenSecret": [[[accArr objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1],
                                     @"fullAccessToken":accessToken
                                     };
    
    RdioAccount *rdioAccount = [MTLJSONAdapter modelOfClass:RdioAccount.class fromJSONDictionary:JSONDictionary error:nil];
    rdioAccount.rdioKey = RDIO_KEY;
    rdioAccount.rdioSecret = RDIO_SECRET;
    UserAccount *userAccount = [PTUtilities readLoginUser];
    userAccount.rdioAccount = rdioAccount;
    [PTUtilities saveLoginUser:userAccount];
    [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"AuthorizationOkMsgKey", nil)];
    if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
        [self.delegate authorizationDidfinished:self success:YES connectType:self.connectType];
    }
}

- (void)rdioAuthorizationFailed:(NSError *)error{
    UALog(@"error:%@",error);
    [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"AuthorizationErrorMsgKey", nil)];

    if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
        [self.delegate authorizationDidfinished:self success:NO connectType:self.connectType];
    }

}

- (void)rdioAuthorizationCancelled{
    [self cancel];
    if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
        [self.delegate authorizationDidfinished:self success:NO connectType:self.connectType];
    }
}

#pragma mark - Action

- (void)cancel{
    [self.webView stopLoading];
    if (self.httpOperation) {
        [self.httpOperation cancel];
    }
    [SVProgressHUD dismiss];
    
}

- (IBAction)cancelAction:(id)sender {
    [self cancel];
    if ([self.delegate respondsToSelector:@selector(authorizationDidfinished:success:connectType:)]) {
        [self.delegate authorizationDidfinished:self success:NO connectType:self.connectType];
    }
}


@end
