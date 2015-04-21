//
//  LikeAndFeederTableViewController.m
//  Duorey
//
//  Created by lixu on 14/12/4.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "LikeAndFeederTableViewController.h"
#import "ProfileViewController.h"
#import "YLRefresh.h"
#import "UserAccount.h"
#import "PTUtilities.h"
#import <SVProgressHUD.h>
#import "PTAppClientEngine.h"
#import "UIImageView+WebCache.h"
#import "LikerAndFeederTableViewCell.h"

#define CELL_ID @"likerAndFeederCell"

@interface LikeAndFeederTableViewController (){
    NSMutableArray *_allListUsers;
    int _pageCount;
}

@end

@implementation LikeAndFeederTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    _pageCount=1;

    NSString *titleStr = self.whereF;
    if (![titleStr isEqualToString:PTNSLocalizedString(@"PlaylistItunesLikerMsgKey", nil)]) {
        titleStr = PTNSLocalizedString(@"PlaylistItunesFeederMsgKey", nil);
    }
    self.title = titleStr;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView addHeaderWithTarget:self action:@selector(dropViewDidBeginRefreshing:)];
    [self.tableView headerBeginRefreshing];
}

- (void)dropViewDidBeginRefreshing:(id)sender{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [PTUtilities readLoginUser];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:user.userId forKey:@"uid"];
    [dic setObject:user.userToken forKey:@"token"];
    [dic setObject:self.listIdStr forKey:@"lid"];
    [dic setObject:@"1" forKey:@"page"];
    if ([self.whereF isEqualToString:PTNSLocalizedString(@"PlaylistItunesLikerMsgKey", nil)]) {
        [[PTAppClientEngine sharedClient] getPlaylistLikersWithDic:dic
                                                        completion:^(NSArray *allUsers,NSError *error){
                                                            __strong typeof(self) strongSelf = weakSelf;
                                                            [strongSelf.tableView headerEndRefreshing];
                                                            if (error==nil) {
                                                                if ([allUsers count]>0) {
                                                                    _allListUsers=(NSMutableArray *)allUsers;
                                                                    _pageCount=2;
                                                                    [self.tableView removeFooter];
                                                                    [self.tableView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                                }else{
                                                                    if (_allListUsers) {
                                                                        [_allListUsers removeAllObjects];
                                                                    }
                                                                }
                                                                [self.tableView reloadData];
                                                            }else{
                                                                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                            }
                                                        }];
    }else{
        [[PTAppClientEngine sharedClient] getPlaylistFeedersWithDic:dic
                                                        completion:^(NSArray *allUsers,NSError *error){
                                                            __strong typeof(self) strongSelf = weakSelf;
                                                            [strongSelf.tableView headerEndRefreshing];
                                                            if (error==nil) {
                                                                if ([allUsers count]>0) {
                                                                    _allListUsers=(NSMutableArray *)allUsers;
                                                                    [self.tableView reloadData];
                                                                    _pageCount=2;
                                                                    [self.tableView removeFooter];
                                                                    [self.tableView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                                }
                                                            }else{
                                                                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                            }
                                                        }];
    }
}


- (void)upViewDidBeginRefreshingFollow:(id)sender{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [PTUtilities readLoginUser];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:user.userId forKey:@"uid"];
    [dic setObject:user.userToken forKey:@"token"];
    [dic setObject:self.listIdStr forKey:@"lid"];
    [dic setObject:[NSString stringWithFormat:@"%d",_pageCount] forKey:@"page"];
    if ([self.whereF isEqualToString:PTNSLocalizedString(@"PlaylistItunesLikerMsgKey", nil)]) {
        [[PTAppClientEngine sharedClient] getPlaylistLikersWithDic:dic
                                                        completion:^(NSArray *allUsers,NSError *error){
                                                            __strong typeof(self) strongSelf = weakSelf;
                                                            if (error==nil) {
                                                                if ([allUsers count]>0) {
                                                                    [_allListUsers addObjectsFromArray:allUsers];
                                                                    [self.tableView reloadData];
                                                                    _pageCount++;
                                                                    [strongSelf.tableView endLoadMoreRefreshing];
                                                                }else{
                                                                    [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                    [strongSelf.tableView endMoreOverWithMessage:@""];
                                                                }
                                                            }else{
                                                                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                            }
                                                        }];
    }else{
        [[PTAppClientEngine sharedClient] getPlaylistFeedersWithDic:dic
                                                         completion:^(NSArray *allUsers,NSError *error){
                                                             __strong typeof(self) strongSelf = weakSelf;
                                                             if (error==nil) {
                                                                 if ([allUsers count]>0) {
                                                                     [_allListUsers addObjectsFromArray:allUsers];
                                                                     [self.tableView reloadData];
                                                                     _pageCount++;
                                                                    [strongSelf.tableView endLoadMoreRefreshing];
                                                                 }else{
                                                                     [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                     [strongSelf.tableView endMoreOverWithMessage:@""];
                                                                 }
                                                             }else{
                                                                 [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                             }
                                                         }];
    }
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
    return [_allListUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LikerAndFeederTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (cell == nil) {
        cell = [[LikerAndFeederTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:CELL_ID];
    }
    UserAccount *user = [_allListUsers objectAtIndex:indexPath.row];
    if (user.userAvatarImageLargeURL!=nil) {
        [cell.iconImageView sd_setImageWithURL:user.userAvatarImageLargeURL
                          placeholderImage:[UIImage imageNamed:@"cellAvatarImage"]];
    }else{
        [cell.iconImageView setImage:[UIImage imageNamed:@"cellAvatarImage"]];
    }
    cell.nameLabel.text = user.nickname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserAccount *user = [_allListUsers objectAtIndex:indexPath.row];
    ProfileViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profile.currentUser = user;
    [self.navigationController pushViewController:profile animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

@end
