//
//  EmailLoginViewController.m
//  Duorey
//
//  Created by xdy on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "EmailSignupViewController.h"
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

@interface EmailSignupViewController ()<UITextFieldDelegate>

//singup view
@property (weak, nonatomic) IBOutlet UITextField *signupEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *signupPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *gotoLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *gotoLoginLabel;

//
@property (strong, nonatomic) UIImageView *errorTipImageView;
@property (nonatomic, strong) SHEmailValidator *emailValidator;
@property (strong, nonatomic) AMPopTip *popTip;
@property (strong, nonatomic) AMPopTip *passworPopTip;
@property (strong, nonatomic) UIImageView *passwordImageView;
@end

@implementation EmailSignupViewController

- (UIImage *)buttonBackgroundImageWithName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 10.0)];
}

- (void)setupUIView{
    self.title = PTNSLocalizedString(@"SignUpTitleMsgKey", nil);
//    id<PTTheme> theme = [PTThemeManager sharedTheme];
    UIImage *errorImage = [UIImage imageNamed:@"emailError"];
    self.errorTipImageView = [[UIImageView alloc] initWithImage:errorImage];
    self.passwordImageView = [[UIImageView alloc] initWithImage:errorImage];
    self.emailValidator = [SHEmailValidator validator];
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    
    self.passworPopTip = [AMPopTip popTip];
    self.passworPopTip.shouldDismissOnTap = YES;
    
    //singup view
    [self.signupEmailTextField setBackground:[self buttonBackgroundImageWithName:@"loginEmail"]];
    UIView *emailLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 33, 44)];
    [emailLeftView setBackgroundColor:[UIColor clearColor]];
    [self.signupEmailTextField setLeftView:emailLeftView];
    [self.signupEmailTextField setLeftViewMode:UITextFieldViewModeAlways];
    self.signupEmailTextField.returnKeyType = UIReturnKeyNext;
    self.signupEmailTextField.tintColor = [UIColor colorWithRed:31.0/255.0 green:206.0/255.0 blue:74.0/255.0 alpha:1.0];
    self.signupEmailTextField.placeholder = PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil);
    self.signupEmailTextField.delegate = self;
    
    [self.signupPasswordTextField setBackground:[self buttonBackgroundImageWithName:@"password"]];
    UIView *passwordLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 33, 44)];
    passwordLeftView.backgroundColor = [UIColor clearColor];
    [self.signupPasswordTextField setLeftView:passwordLeftView];
    [self.signupPasswordTextField setLeftViewMode:UITextFieldViewModeAlways];
    self.signupPasswordTextField.returnKeyType = UIReturnKeyDone;
    self.signupPasswordTextField.secureTextEntry = YES;
    self.signupPasswordTextField.delegate = self;
    self.signupPasswordTextField.tintColor = [UIColor colorWithRed:31.0/255.0 green:206.0/255.0 blue:74.0/255.0 alpha:1.0];
    self.signupPasswordTextField.placeholder = PTNSLocalizedString(@"PasswordPlaceholderMsgKey", nil);
    [self.createAccountButton setTitle:PTNSLocalizedString(@"CreateAccountButtonMsgKey", nil) forState:UIControlStateNormal];
    self.gotoLoginLabel.text = PTNSLocalizedString(@"gotoLoginLabelMsgKey", nil);
    [self.gotoLoginButton setTitle:PTNSLocalizedString(@"gotoLoginButtonMsgKey", nil) forState:UIControlStateNormal];
}

- (void)updateButtonEnableStateForTextField {
    self.createAccountButton.enabled = NO;
    [self.signupEmailTextField addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)textFieldEditing:(UITextField *)textField {
    self.createAccountButton.enabled = [textField.text length] > 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self updateButtonEnableStateForTextField];
    
    [self setupUIView];
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailRegCategory action:@"in" label:@"login_email_in" value:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailRegCategory action:@"out" label:@"login_email_out" value:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button Action

//signup
- (IBAction)createAccountButtonAction:(id)sender {
    [self.signupPasswordTextField resignFirstResponder];
    [self.signupEmailTextField resignFirstResponder];
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    
    if (self.signupEmailTextField.text==nil || [self.signupEmailTextField.text isEmpty]) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil)];
        return;
    }
    
    if ([self.signupPasswordTextField.text isEmpty]|| [[self.signupPasswordTextField.text trim] length]<6 || [[self.signupPasswordTextField.text trim] length] > 18) {
        [self validatePassword:self.signupPasswordTextField];
        return;
    }
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailRegCategory action:@"Click_creat" label:@"creat_account" value:nil];
    
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"CreateAccountLoadingMsgKey", nil)
                         maskType:SVProgressHUDMaskTypeBlack];
    [[PTAppClientEngine sharedClient] emailSignupDuoreySystemWithEmail:[self.signupEmailTextField.text trim] password:[self.signupPasswordTextField.text trim] userType:UserTypeSystem completion:^(UserAccount *user, NSError *error) {
        //
        if (!error) {
            postNotification(DuoreyDidLoginNotification, user, nil);
            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"CreateAccountOkMsgKey", nil)];
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
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailRegCategory action:@"Click_login_email_login" label:@"login_email" value:nil];
}


#pragma mark - UITextFieldDelegate

-(void)validatePassword:(UITextField *)textField
{
    if (textField == self.signupPasswordTextField) {
        NSString *password = [textField.text trim];
        if (password.length > 18 || password.length < 6)
        {
            CGSize imageSize = self.passwordImageView.frame.size;
            CGRect textFrame = _signupPasswordTextField.frame;
            CGFloat diffValue = CGRectGetHeight(textFrame)/2-imageSize.height/2;//错误图片在TextField居中时，左右上下相距多少
            self.passwordImageView.frame = CGRectMake(CGRectGetMaxX(textFrame)-imageSize.width-1, CGRectGetMinY(textFrame)+diffValue, imageSize.width, imageSize.height);
            
            [self.view addSubview:self.passwordImageView];
            [self.passworPopTip showText:PTNSLocalizedString(@"PasswordPlaceholderMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.passwordImageView.frame];
        }
    }
}

- (void)validateInput:(UITextField *)textField
{
    NSString *eamil = [textField.text trim];
    if (eamil.length > 0)
    {
        CGSize imageSize = self.errorTipImageView.frame.size;
        CGRect textFrame = textField.frame;
        CGFloat diffValue = CGRectGetHeight(textFrame)/2-imageSize.height/2;//错误图片在TextField居中时，左右上下相距多少
        self.errorTipImageView.frame = CGRectMake(CGRectGetMaxX(textFrame)-imageSize.width-1, CGRectGetMinY(textFrame)+diffValue, imageSize.width, imageSize.height);
        if (eamil.length > 60 && [textField isEqual:self.signupEmailTextField])
        {
            [self.view addSubview:self.errorTipImageView];
            [self.popTip showText:PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.errorTipImageView.frame];
            self.createAccountButton.enabled = NO;
            return;
        }
        NSError *error;
        [self.emailValidator validateAndAutocorrectEmailAddress:eamil withError:&error];
        
        if (error) {
            if (textField == self.signupEmailTextField) {
                self.createAccountButton.enabled = NO;
            }
            
            [self.view addSubview:self.errorTipImageView];
            [self.popTip showText:PTNSLocalizedString(@"EmailErrorMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.errorTipImageView.frame];
        }else{
            if (textField == self.signupEmailTextField) {
                self.createAccountButton.enabled = YES;
            }
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.signupEmailTextField) {
        [self.popTip hide];
        [self.errorTipImageView removeFromSuperview];
    }
    if (textField == self.signupPasswordTextField) {
        [self.passworPopTip hide];
        [self.passwordImageView removeFromSuperview];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.signupEmailTextField) {
        if (textField.text != nil && [[textField.text trim] length]>0) {
            [self validateInput:textField];
        }
    }
    if (textField == self.signupPasswordTextField) {
        if (textField.text != nil && [[textField.text trim] length]>0) {
            [self validatePassword:textField];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.signupEmailTextField) {
        [self validateInput:textField];
        [self.signupPasswordTextField becomeFirstResponder];
    }else if (textField == self.signupPasswordTextField){
        [self.signupPasswordTextField resignFirstResponder];
    }
    
    return NO;
}

@end
