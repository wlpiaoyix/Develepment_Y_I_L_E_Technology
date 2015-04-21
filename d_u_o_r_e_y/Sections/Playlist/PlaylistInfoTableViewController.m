//
//  PlaylistInfoTableViewController.m
//  Duorey
//
//  Created by lixu on 14/11/25.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistInfoTableViewController.h"
#import "PTDefinitions.h"
#import "UIImage+Compress.h"
#import "UserAccount.h"
#import "PTUtilities.h"
#import "PTAppClientEngine.h"
#import "UIImageView+WebCache.h"
#import "RSKImageCropper.h"
#import <AVFoundation/AVFoundation.h>

@interface PlaylistInfoTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UIActionSheetDelegate,UITextViewDelegate,UITextFieldDelegate,RSKImageCropViewControllerDataSource,RSKImageCropViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *userDescTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic ) BOOL isChangeImage;

@end

@implementation PlaylistInfoTableViewController

- (UserAccount *)userAccount{
   return [PTUtilities unarchiveObjectWithName:@"me"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    _nameTextField.delegate=self;
    _userDescTextView.delegate=self;

    _isChangeImage = NO;
    if (![PTUtilities isEmptyOrNull:self.playlistObj.listIcon]) {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:self.playlistObj.listIcon]
                          placeholderImage:[UIImage imageNamed:@"DefaultCoverNo2"]];
    }else{
        [_iconImageView setImage:[UIImage imageNamed:@"DefaultCoverNo2"]];
    }
    _nameTextField.text = self.playlistObj.listName;
    _userDescTextView.text = self.playlistObj.comments;
    UserAccount *user = [self userAccount];
    if([self.playlistObj.creater intValue]!=[user.userId intValue]){
        [_nameTextField setEnabled:NO];
        [_userDescTextView setEditable:NO];
    }else{
        [_nameTextField setEnabled:YES];
        [_userDescTextView setEditable:YES];
        self.navigationItem.rightBarButtonItem = _doneButton;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return 3;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *identifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell==nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 100, 40)];
//    [label setFont:[UIFont boldSystemFontOfSize:17]];
//    [cell addSubview:label];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width-20, 17, 10, 15)];
//    [imageView setImage:[UIImage imageNamed:@"jiantou"]];
//    [cell addSubview:imageView];
//    if (indexPath.row==0) {
//        [label setText:@"Cover"];
//    }else if (indexPath.row==1){
//        [label setText:@"Name"];
//    }else{
//        [label setText:@"Desoription"];
//    }
//    
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row==2) return 200;
//    return 50.0f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserAccount *user = [self userAccount];
    if([self.playlistObj.creater intValue]!=[user.userId intValue]){
        return;
    }
    switch (indexPath.row) {
        case 0:
        {
            [self.nameTextField resignFirstResponder];
            [self.userDescTextView resignFirstResponder];
            [self showImageSelected];
        }
            break;
        case 1:
        {
            [self.nameTextField becomeFirstResponder];
        }
            break;
        case 2:
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
    
    CGRect rect  = CGRectMake(0, (height-width/2)/2, width, width/2);
    return rect;
}

- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller {
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    
    UIBezierPath *path;
    CGRect rect = CGRectMake(0, (height-width/2)/2, width, width/2);
    path = [UIBezierPath bezierPathWithRect:rect];
    
    return path;
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    _isChangeImage = YES;
    CGFloat imageHeight = croppedImage.size.height;
    CGFloat imageWeight = croppedImage.size.width;
    self.iconImageView.image = [croppedImage imageToScaleSize:CGSizeMake(imageWeight/4*3, imageHeight/4*3) withSizeType:ImageResizingScale];
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
    if (textField == self.nameTextField) {
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

#pragma mark -  scrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.nameTextField resignFirstResponder];
    [self.userDescTextView resignFirstResponder];
}

#pragma mark - Action
- (IBAction)doneButtonAction:(id)sender {
    NSString *listName = _nameTextField.text;
    if ([PTUtilities isEmptyOrNull:listName] || [self getToInt:listName]>30) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"PlaylistNameIllegalMsgKey", nil)];
        return;
    }
    if (![PTUtilities isEmptyOrNull:_userDescTextView.text] && [self getToInt:_userDescTextView.text]>200) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"PlaylistCommentIllegalMsgKey", nil)];
        return;
    }
    NSString *comStr = _userDescTextView.text;
    NSString *imageStr = [self base64ImageData:_iconImageView.image];
    
    UserAccount *user = [self userAccount];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:user.userId forKey:@"uid"];
    [dic setObject:user.userToken forKey:@"token"];
    [dic setObject:self.listId forKey:@"lid"];
    if (_isChangeImage) {
        [dic setObject:imageStr forKey:@"cover"];
    }
    [dic setObject:listName forKey:@"list_name"];
    [dic setObject:comStr forKey:@"comments"];
    
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"UpdateLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[PTAppClientEngine sharedClient] editPlaylistInfoWithDic:dic
                                                   completion:^(NSError *error){
                                                       if (error) {
                                                           [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                       }else{
                                                           [SVProgressHUD dismiss];
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }
                                                   }];
}

- (int)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return (int)[da length];
}

//图片转base64
- (NSString *)base64ImageData:(UIImage *)image{
    NSData *imageData = [image imageJPEGRepresentationWithCompressionQuality:0.6];
    return [imageData base64EncodedStringWithOptions:0];
}

@end
