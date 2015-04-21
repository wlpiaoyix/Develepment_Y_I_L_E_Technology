//
//  EmailLoginViewController.m
//  Duorey
//
//  Created by xdy on 14/11/7.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "EmailForgetViewController.h"
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

@interface EmailForgetViewController ()<UITextFieldDelegate>

//forgot view
@property (weak, nonatomic) IBOutlet UILabel *forgotTipLabel;
@property (weak, nonatomic) IBOutlet UITextField *forgotEmailTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendForgotButton;

//
@property (strong, nonatomic) UIImageView *errorTipImageView;
@property (nonatomic, strong) SHEmailValidator *emailValidator;
@property (strong, nonatomic) AMPopTip *popTip;
@end

@implementation EmailForgetViewController

- (UIImage *)buttonBackgroundImageWithName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 10.0)];
}

- (void)setupUIView{
    self.title = PTNSLocalizedString(@"FindPasswordTitleMsgKey", nil);
//    id<PTTheme> theme = [PTThemeManager sharedTheme];
    UIImage *errorImage = [UIImage imageNamed:@"emailError"];
    self.errorTipImageView = [[UIImageView alloc] initWithImage:errorImage];
    self.emailValidator = [SHEmailValidator validator];
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    
    //forgot view
    [self.forgotEmailTextField setBackground:[self buttonBackgroundImageWithName:@"loginEmail"]];
    UIView *emailLeftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 33, 44)];
    [emailLeftView2 setBackgroundColor:[UIColor clearColor]];
    [self.forgotEmailTextField setLeftView:emailLeftView2];
    [self.forgotEmailTextField setLeftViewMode:UITextFieldViewModeAlways];
    self.forgotEmailTextField.returnKeyType = UIReturnKeyDone;
    self.forgotEmailTextField.tintColor = [UIColor colorWithRed:31.0/255.0 green:206.0/255.0 blue:74.0/255.0 alpha:1.0];
    self.forgotEmailTextField.placeholder = PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil);
    self.forgotEmailTextField.delegate = self;
    [self.sendForgotButton setTitle:PTNSLocalizedString(@"sendForgotButtonMsgKey", nil) forState:UIControlStateNormal];
    self.forgotTipLabel.text = PTNSLocalizedString(@"forgotTipLabelMsgKey", nil);
}

- (void)updateButtonEnableStateForTextField {
    self.sendForgotButton.enabled = NO;
    [self.forgotEmailTextField addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)textFieldEditing:(UITextField *)textField {
    self.sendForgotButton.enabled = [textField.text length] > 0;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button Action

//forgot password
- (IBAction)forgotPasswordButtonAction:(id)sender {
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    
    NSError *error;
    [self.emailValidator validateAndAutocorrectEmailAddress:[self.forgotEmailTextField.text trim] withError:&error];
    
    if (error || [[self.forgotEmailTextField.text trim] length]>60) {
        [self validateInput:self.forgotEmailTextField];
        [self.forgotEmailTextField resignFirstResponder];
        return;
    }
    
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"F_login_email_login_find" action:@"Click_findpassword_1" label:@"send_mail" value:nil];
    
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"ResetPaswordLoadingMsgKey", nil)
                         maskType:SVProgressHUDMaskTypeBlack];
    __block EmailForgetViewController *weakSelf = self;
    [[PTAppClientEngine sharedClient] emailForgotPasswordWithEmail:[self.forgotEmailTextField.text trim] userType:UserTypeSystem completion:^(NSError *error) {
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"ResetEmailOKMsgKey", nil)];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}

/**/
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:kFloginEmailLoginCategory action:@"Click_findpassword" label:@"find_password" value:nil];
}


#pragma mark - UITextFieldDelegate

- (void)validateInput:(UITextField *)textField
{
    NSString *email = [textField.text trim];
    if (email.length > 0)
    {
        CGSize imageSize = self.errorTipImageView.frame.size;
        CGRect textFrame = textField.frame;
        CGFloat diffValue = CGRectGetHeight(textFrame)/2-imageSize.height/2;//错误图片在TextField居中时，左右上下相距多少
        self.errorTipImageView.frame = CGRectMake(CGRectGetMaxX(textFrame)-imageSize.width-1, CGRectGetMinY(textFrame)+diffValue, imageSize.width, imageSize.height);
        if (email.length > 60 && [textField isEqual:self.forgotEmailTextField])
        {
            [self.view addSubview:self.errorTipImageView];
            [self.popTip showText:PTNSLocalizedString(@"EmailPlaceholderMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.errorTipImageView.frame];
            self.sendForgotButton.enabled = NO;
            return;
        }
        NSError *error;
        [self.emailValidator validateAndAutocorrectEmailAddress:email withError:&error];
        
        if (error) {
            self.sendForgotButton.enabled = NO;
            
            [self.view addSubview:self.errorTipImageView];
            [self.popTip showText:PTNSLocalizedString(@"EmailErrorMsgKey", nil) direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:self.errorTipImageView.frame];
        }else{
            self.sendForgotButton.enabled = YES;
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.forgotEmailTextField) {
        [self.popTip hide];
        [self.errorTipImageView removeFromSuperview];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.forgotEmailTextField) {
        if (textField.text != nil && [[textField.text trim] length]>0) {
            [self validateInput:textField];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.forgotEmailTextField) {
        [self validateInput:textField];
        [self.forgotEmailTextField resignFirstResponder];
    }
    
    return NO;
}

@end
