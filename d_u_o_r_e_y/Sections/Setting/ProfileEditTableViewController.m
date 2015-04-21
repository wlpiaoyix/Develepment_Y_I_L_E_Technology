//
//  ProfileEditTableViewController.m
//  Duorey
//
//  Created by xdy on 14/11/20.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ProfileEditTableViewController.h"
#import "PTDefinitions.h"
#import "UIImage+Compress.h"
#import <SVProgressHUD.h>
#import "PTAppClientEngine.h"
#import "UIImageView+WebCache.h"
#import "RSKImageCropper.h"
#import <AVFoundation/AVFoundation.h>

@interface ProfileEditTableViewController ()<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *userDescTextView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *avatarNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *backgroundNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDescNameLabel;


@property (strong, nonatomic) NSString *typeName;
@end

@implementation ProfileEditTableViewController

- (void)updateUserProfile:(UserAccount *)userAccount{
    if (userAccount.userAvatarImageLargeURL == nil) {
        self.avatarImageView.image = [UIImage imageNamed:@"avatarImage"];
    }else{
        [self.avatarImageView sd_setImageWithURL:userAccount.userAvatarImageLargeURL placeholderImage:[UIImage imageNamed:@"avatarImage"]];
    }
    
    if (userAccount.userCoverURL == nil) {
        self.backgroundImageView.image = [UIImage imageNamed:@"BgProfile"];
    }else{
        [self.backgroundImageView sd_setImageWithURL:userAccount.userCoverURL placeholderImage:[UIImage imageNamed:@"BgProfile"]];
    }
    self.nickNameTextField.text = userAccount.nickname;
    self.userDescTextView.text = userAccount.userSig;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    self.title = PTNSLocalizedString(@"ProfileInfoTitleMsgKey", nil);
    self.avatarNameLabel.text = PTNSLocalizedString(@"ProfileInfoAvatarMsgKey", nil);
    self.backgroundNameLabel.text = PTNSLocalizedString(@"ProfileInfoCoverMsgKey", nil);
    self.nickNameLabel.text = PTNSLocalizedString(@"ProfileInfoNicknameMsgKey", nil);
    self.userDescNameLabel.text = PTNSLocalizedString(@"ProfileInfoUserSigMsgKey", nil);
    self.typeName = @"";
    self.nickNameTextField.delegate = self;
    self.userDescTextView.delegate = self;
    
    [self updateUserProfile:self.currentAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            self.cropRectType = CropRectSquare;
            self.typeName = self.avatarNameLabel.text;
            [self showImageSelected];
        }
            break;
        case 1:
        {
            self.cropRectType = CropRectRectangle;
            self.typeName = self.backgroundNameLabel.text;
            [self showImageSelected];
        }
            break;
        case 2:
        {
            [self.nickNameTextField becomeFirstResponder];
        }
            break;
        case 3:
        {
            [self.userDescTextView becomeFirstResponder];
        }
            break;
        default:
            break;
    }
}

- (void)showImageSelected{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey",nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:PTNSLocalizedString(@"CameraButtonMsgKey",nil), PTNSLocalizedString(@"PhotoLibraryButtonMsgKey",nil), nil];
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate

- (void)createImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = sourceType;
//    controller.allowsEditing = YES;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (buttonIndex == 0) {
        // camera
        if([self isCameraAvailable]) {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        AVAuthorizationStatus cameraAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (cameraAuthorizationStatus == AVAuthorizationStatusDenied || cameraAuthorizationStatus == AVAuthorizationStatusRestricted) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:PTNSLocalizedString(@"CameraNotAuthorizatedTitleKey", @"determin the authorization status when use camera") message:PTNSLocalizedString(@"CameraNotAuthorizatedMessageKey", @"instructions to authorize camera usage") delegate:nil cancelButtonTitle:PTNSLocalizedString(@"OKButtonMsgKey", nil) otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            [self createImagePickerControllerWithSourceType:sourceType];
        }
    } else if (buttonIndex == 1) {
        // PhotoLibrary
        [self createImagePickerControllerWithSourceType:sourceType];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (image == nil){
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCustom];
        imageCropVC.delegate = self;
        imageCropVC.dataSource = self;
        imageCropVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:imageCropVC animated:YES];
    }];
}

#pragma mark - RSKImageCropViewControllerDataSource

- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller {
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    
    CGRect rect;
    
    if (self.cropRectType == CropRectSquare) {
        rect = CGRectMake(0, (height-width)/2, width, width);
    } else if (self.cropRectType == CropRectRectangle) {
        rect = CGRectMake(0, (height-width/2)/2, width, width/2);
    }
    return rect;
}

- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller {
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    
    CGRect rect;
    
    if (self.cropRectType == CropRectSquare) {
        rect = CGRectMake(0, (height-width)/2, width, width);
        
    } else if (self.cropRectType == CropRectRectangle) {
        rect = CGRectMake(0, (height-width/2)/2, width, width/2);
    }
    
    return [UIBezierPath bezierPathWithRect:rect];
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    if ([self.typeName isEqualToString:PTNSLocalizedString(@"ProfileInfoAvatarMsgKey", nil)]) {
        self.avatarImageView.image = [croppedImage imageToScaleSize:CGSizeMake(100 * 3, 100 * 3) withSizeType:ImageResizingScale];
        self.typeName = @"";
        self.currentAccount.userAvatarImageLargeURL = nil;
    }else{
        CGFloat imageHeight = croppedImage.size.height;
        CGFloat imageWeight = croppedImage.size.width;
        self.backgroundImageView.image = [croppedImage imageToScaleSize:CGSizeMake(imageWeight/4*3, imageHeight/4*3) withSizeType:ImageResizingScale];
        self.typeName = @"";
        self.currentAccount.userCoverURL = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nickNameTextField) {
        [textField resignFirstResponder];
        [self.userDescTextView becomeFirstResponder];
    }
    
    return NO;
}

#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Action

- (NSString *)base64ImageData:(UIImage *)image{
    NSData *imageData = [image imageJPEGRepresentationWithCompressionQuality:0.6];
    return [imageData base64EncodedStringWithOptions:0];
}

- (IBAction)updateUserProfileAction:(UIBarButtonItem *)sender {
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        return;
    }
    
    //判断
    NSString *nickname = self.nickNameTextField.text;
    if (nickname == nil || [nickname isEmpty]) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NicknameLimitMsgKey", nil)];
        return;
    }
    
    if (nickname.length>30) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NicknameLengthLimitMsgKey", nil)];
        return;
    }
    
    NSString *userDesc = self.userDescTextView.text;
    if (![PTUtilities isEmptyOrNull:userDesc] && userDesc.length>100) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"SigLimitMsgKey", nil)];
        return;
    }
    
    if ([nickname isEqualToString:self.currentAccount.nickname]
        && [userDesc isEqualToString:self.currentAccount.userSig]
        && self.currentAccount.userAvatarImageLargeURL != nil
        && self.currentAccount.userCoverURL != nil) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NotChangeAnythingMsgKey", nil)];
        return;
    }
    
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"UpdateLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) weakSelf = self;
    [[PTAppClientEngine sharedClient] updateUserProfileWithUserId:self.currentAccount.userId
                                                            token:self.currentAccount.userToken
                                                      avatarImage:[self base64ImageData:self.avatarImageView.image]
                                                   backgroundImage:[self base64ImageData:self.backgroundImageView.image]
                                                         nickName:nickname
                                                         userDesc:userDesc
                                                       completion:^(UserAccount *user, NSError *error) {
                                                           if (error) {
                                                               [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                           }else{
                                                               [SVProgressHUD dismiss];
                                                               __strong typeof(self) strongSelf = weakSelf;
                                                               [strongSelf updateUserProfile:user];
                                                               [strongSelf.navigationController popViewControllerAnimated:YES];
                                                               if ([strongSelf.delegate respondsToSelector:@selector(didProfileUpdate:)]) {
                                                                   [strongSelf.delegate didProfileUpdate:strongSelf];
                                                               }
                                                           }
                                                       }];
}


@end
