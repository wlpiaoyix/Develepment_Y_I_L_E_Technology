//
//  EmailLoginViewController.m
//  Duorey
//
//  Created by xdy on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "EmailLoginViewController.h"
#import <SHEmailValidationTextField.h>
#import <SHEmailValidator.h>
#import <SVProgressHUD.h>
#import "PTAppClientEngine.h"
#import "PTConstant.h"
#import "PTTheme.h"
#import <AMPopTip.h>
#import "NSString+Additions.h"

#define kFloginEmailRegCategory @"F_login_email"
#define kFloginEmailLoginCategory @"F_login_email_login"

@interface EmailLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *loginEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *gotoForgotButton;

//
@property (strong, nonatomic) UIImageView *errorTipImageView;
@property (nonatomic, strong) SHEmailValidator *emailValidator;
@property (strong, nonatomic) AMPopTip *popTip;
@property (strong, nonatomic) AMPopTip *passworPopTip;
@property (strong, nonatomic) UIImageView *passwordImageView;
@end

@implementation EmailLoginViewController

- (UIImage *)buttonBackgroundImageWithName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 10.0)];
}

- (void)setupUIView{
    self.title = PTNSLocalizedString(@"LoginTitleMsgKey", nil);
//    id<PTTheme> theme = [PTThemeManager sharedTheme];
    UIImage *errorImage = [UIImage imageNamed:@"emailError"];
    self.errorTipImageView = [[UIImageView alloc] initWithImage:errorImage];
    self.passwordImageView = [[UIImageView alloc] initWithImage:errorImage];
    self.emailValidator = [SHEmailValidator validator];
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    
    self.passworPopTip = [AMPopTip popTip];
    self.passworPopTip.shouldDismissOnTap = YES;
    
    //login view
    [self.loginEmailTextField setBackground:[self buttonBackgroundImageWithName:@"loginEmail"]];
    UIView *emailLeftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 33, 44)];
    [emailLeftView1 setBackgroundColor:[UIColor clearColor]];
    [self.loginEmailTextField setLeftView:emailLeftView1];
    [self.loginEmailTextField setLeftViewMode:UITextFieldViewModeAlways];
    self.loginEmailTextField.returnKeyType = UIReturnKeyNext;
    self.loginEmailTextField.tintColor = [UIColor colorWithRed:31.0/255.0 green:206.0/255.0 blue:74.0/255.0 alpha:1.0];
    self.loginEmailTextField.placeholder = PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil);
    self.loginEmailTextField.delegate = self;
    
    [self.loginPasswordTextField setBackground:[self buttonBackgroundImageWithName:@"password"]];
    UIView *passwordLeftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 33, 44)];
    passwordLeftView1.backgroundColor = [UIColor clearColor];
    [self.loginPasswordTextField setLeftView:passwordLeftView1];
    [self.loginPasswordTextField setLeftViewMode:UITextFieldViewModeAlways];
    self.loginPasswordTextField.returnKeyType = UIReturnKeyDone;
    self.loginPasswordTextField.secureTextEntry = YES;
    self.loginPasswordTextField.delegate = self;
    self.loginPasswordTextField.tintColor = [UIColor colorWithRed:31.0/255.0 green:206.0/255.0 blue:74.0/255.0 alpha:1.0];
    self.loginPasswordTextField.placeholder = PTNSLocalizedString(@"PasswordPlaceholderMsgKey", nil);
    [self.loginButton setTitle:PTNSLocalizedString(@"LoginButtonMsgKey", nil) forState:UIControlStateNormal];
    [self.gotoForgotButton setTitle:PTNSLocalizedString(@"gotoForgotButtonMsgKey", nil) forState:UIControlStateNormal];
}

- (void)updateButtonEnableStateForTextField {
    self.loginButton.enabled = NO;
    [self.loginEmailTextField addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)textFieldEditing:(UITextField *)textField {
    self.loginButton.enabled = [textField.text length] > 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self updateButtonEnableStateForTextField];
    
    [self setupUIView];
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailLoginCategory action:@"in" label:@"login_email_login_in" value:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailLoginCategory action:@"out" label:@"login_email_login_out" value:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button Action

//login
- (IBAction)loginButtonAction:(id)sender {
    [self.loginPasswordTextField resignFirstResponder];
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    
    if (self.loginEmailTextField.text==nil || [self.loginEmailTextField.text isEmpty]) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil)];
        return;
    }
    
    if ([self.loginPasswordTextField.text isEmpty]|| [[self.loginPasswordTextField.text trim] length]<6 || [[self.loginPasswordTextField.text trim] length] > 18) {
        [self validatePassword:self.loginPasswordTextField];
        return;
    }
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailLoginCategory action:@"Click_login_email_login_1" label:@"login_email_1" value:nil];
    
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"LoginLoadingMsgKey", nil)
                         maskType:SVProgressHUDMaskTypeBlack];
    [[PTAppClientEngine sharedClient] emailLoginDuoreySystemWithEmail:[self.loginEmailTextField.text trim] password:[self.loginPasswordTextField.text trim] completion:^(UserAccount *user, NSError *error) {
        //
        if (!error) {
            postNotification(DuoreyDidLoginNotification, user, nil);
            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"LoginOKMsgKey", nil)];
        }else{
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
    [PTUtilities setNeedRefrshPlaylist:YES];
}

/*
#pragma mark - Navigation
*/
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailLoginCategory action:@"Click_findpassword" label:@"find_password" value:nil];
}


#pragma mark - UITextFieldDelegate

-(void)validatePassword:(UITextField *)textField
{
    if (textField == self.loginPasswordTextField) {
        NSString *password = [textField.text trim];
        if (password.length > 18 || password.length < 6)
        {
            CGSize imageSize = self.passwordImageView.frame.size;
            CGRect textFrame = self.loginPasswordTextField.frame;
            CGFloat diffValue = CGRectGetHeight(textFrame)/2-imageSize.height/2;//错误图片在TextField居中时，左右上下相距多少
            self.passwordImageView.frame = CGRectMake(CGRectGetMaxX(textFrame)-imageSize.width-1, CGRectGetMinY(textFrame)+diffValue, imageSize.width, imageSize.height);
            
            [self.view addSubview:self.passwordImageView];
            [self.passworPopTip showText:PTNSLocalizedString(@"PasswordPlaceholderMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.passwordImageView.frame];
        }
    }

}

- (void)validateInput:(UITextField *)textField
{
    NSString *email = [textField.text trim];
    if (email.length > 0)
    {
        CGSize imageSize = self.errorTipImageView.frame.size;
        CGRect textFrame = textField.frame;
        CGFloat diffValue = CGRectGetHeight(textFrame)/2-imageSize.height/2;//错误图片在TextField居中时，左右上下相距多少
        self.errorTipImageView.frame = CGRectMake(CGRectGetMaxX(textFrame)-imageSize.width-1, CGRectGetMinY(textFrame)+diffValue, imageSize.width, imageSize.height);
        if (email.length > 60 && [textField isEqual:self.loginEmailTextField])
        {
            [self.view addSubview:self.errorTipImageView];
            [self.popTip showText:PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.errorTipImageView.frame];
            self.loginButton.enabled = NO;
            return;
        }
        NSError *error;
        [self.emailValidator validateAndAutocorrectEmailAddress:email withError:&error];
        
        if (error) {
            
            if(textField == self.loginEmailTextField ){
                self.loginButton.enabled = NO;
            }
            
            [self.view addSubview:self.errorTipImageView];
            [self.popTip showText:PTNSLocalizedString(@"EmailErrorMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.errorTipImageView.frame];
        }else{
            if(textField == self.loginEmailTextField ){
                self.loginButton.enabled = YES;
            }
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.loginEmailTextField) {
        [self.popTip hide];
        [self.errorTipImageView removeFromSuperview];
    }
    if (textField == self.loginPasswordTextField) {
        [self.passworPopTip hide];
        [self.passwordImageView removeFromSuperview];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.loginEmailTextField) {
        if (textField.text != nil && [textField.text length]>0) {
            [self validateInput:textField];
        }
    }
    if (textField == self.loginPasswordTextField) {
        if (textField.text != nil && [textField.text length]>0) {
            [self validatePassword:textField];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.loginEmailTextField) {
        [self validateInput:textField];
        [self.loginPasswordTextField becomeFirstResponder];
    }else if (textField == self.loginPasswordTextField){
        [self.loginPasswordTextField resignFirstResponder];
    }
    
    return NO;
}

@end
