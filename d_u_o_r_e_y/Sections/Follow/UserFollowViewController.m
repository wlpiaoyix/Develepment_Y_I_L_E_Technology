//
//  UserFollowViewController.m
//  Duorey
//
//  Created by xdy on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "UserFollowViewController.h"
#import "YLRefresh.h"
#import "PTAppClientEngine.h"
#import "UIImageView+WebCache.h"
#import "ProfileViewController.h"
#import "UserFollowCell.h"

@interface UserFollowViewController (){
    NSInteger _currentPage;
    NSMutableArray *_currentUsers;
}

@end

@implementation UserFollowViewController

@synthesize userId = _userId;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    _currentPage = 1;
    _currentUsers = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:[UserFollowCell xibName] bundle:nil] forCellReuseIdentifier:[UserFollowCell reuseIdentifier]];
    
    if ([_currentUsers count]) {
         self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    [self setupRefresh];
}

- (void)setupRefresh{
    [self.tableView addHeaderWithTarget:self action:@selector(dropViewDidBeginRefreshingFollow:) dateKey:[NSString stringWithFormat:@"user-follow%@",self.userId]];
    [self.tableView headerBeginRefreshing];
    [self.tableView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _currentUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UserFollowCell cellHeight];
}

/**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserFollowCell reuseIdentifier] forIndexPath:indexPath];
    UserAccount *user = _currentUsers[indexPath.row];
    // Configure the cell...
    if (user.userAvatarImageLargeURL==nil) {
        cell.userAvatarImageView.image = [UIImage imageNamed:@"avatarImage"];
    }else{
        [cell.userAvatarImageView sd_setImageWithURL:user.userAvatarImageLargeURL placeholderImage:[UIImage imageNamed:@"avatarImage"]];
    }
    cell.userNickNameLabel.text = user.nickname;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showOtherUserDetail" sender:cell];
}


/**/
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showOtherUserDetail"]) {
        ProfileViewController *profileVC = segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        UserAccount *user = _currentUsers[indexPath.row];
        profileVC.currentUser = user;
    }
}


#pragma mark - dropDown

- (void)dropViewDidBeginRefreshingFollow:(id)sender{
    [self.tableView removeFooter];
    [self.tableView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        [self.tableView headerEndRefreshing];
        return;
    }
    
    _currentPage = 1;
    if (_currentUsers) {
        [_currentUsers removeAllObjects];
    }
    UserAccount *userAccount = [PTUtilities readLoginUser];
    __weak typeof(self) weakSelf = self;
    if (self.followType == UserFollowTypeFollow) {
        [[PTAppClientEngine sharedClient] fetchUserFollowUsersWithUserId:userAccount.userId
                                                                   token:userAccount.userToken
                                                                    page:_currentPage
                                                             otherUserId:self.userId
                                                              completion:^(NSArray *follows, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }else{
                if (follows==nil || [follows count]==0) {
                    [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"FollowingUsersNoneMessageKey", nil)];
                }else{
                    _currentPage++;
                    [_currentUsers addObjectsFromArray:follows];
                }
            }
             __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.tableView headerEndRefreshing];
            [strongSelf.tableView reloadData];
        }];
    }else{
        [[PTAppClientEngine sharedClient] fetchUserFollowedUsersWithUserId:userAccount.userId
                                                                     token:userAccount.userToken
                                                                      page:_currentPage
                                                               otherUserId:self.userId
                                                                completion:^(NSArray *followeds, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }else{
                if (followeds==nil || [followeds count]==0) {
                    [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"FollowedUsersNoneMessageKey", nil)];
                }else{
                    _currentPage++;
                    [_currentUsers addObjectsFromArray:followeds];
                }
            }
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.tableView headerEndRefreshing];
            [strongSelf.tableView reloadData];
        }];
    }
}

- (void)upViewDidBeginRefreshingFollow:(id)sender{
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        [self.tableView endMoreOverWithMessage:@""];
        return;
    }
    UserAccount *userAccount = [PTUtilities readLoginUser];
    __weak typeof(self) weakSelf = self;
    if (self.followType == UserFollowTypeFollow) {
        [[PTAppClientEngine sharedClient] fetchUserFollowUsersWithUserId:userAccount.userId
                                                                   token:userAccount.userToken
                                                                    page:_currentPage
                                                             otherUserId:self.userId
                                                              completion:^(NSArray *follows, NSError *error) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
            if (error) {
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }else{
                if (follows==nil || [follows count]==0) {
                    [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"FollowingUsersNoneMessageKey", nil)];
                    [strongSelf.tableView endMoreOverWithMessage:@""];
                }else{
                    _currentPage++;
                    [_currentUsers addObjectsFromArray:follows];
                    [strongSelf.tableView endLoadMoreRefreshing];
                }
            }
//            [strongSelf.tableView footerEndRefreshing];
            [strongSelf.tableView reloadData];
        }];
    }else{
        [[PTAppClientEngine sharedClient] fetchUserFollowedUsersWithUserId:userAccount.userId
                                                                     token:userAccount.userToken
                                                                      page:_currentPage
                                                               otherUserId:self.userId
                                                                completion:^(NSArray *followeds, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (error) {
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }else{
                if (followeds==nil || [followeds count]==0) {
                    [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"FollowedUsersNoneMessageKey", nil)];
                    [strongSelf.tableView endMoreOverWithMessage:@""];
                }else{
                    _currentPage++;
                    [_currentUsers addObjectsFromArray:followeds];
                    [strongSelf.tableView endLoadMoreRefreshing];
                }
            }
            
//            [strongSelf.tableView footerEndRefreshing];
            [strongSelf.tableView reloadData];
        }];
    }
}

@end
