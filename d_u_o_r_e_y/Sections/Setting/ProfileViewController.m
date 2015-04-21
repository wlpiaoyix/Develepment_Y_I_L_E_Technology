//
//  ProfileViewController.m
//  Duorey
//
//  Created by xdy on 14/11/11.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ProfileViewController.h"
#import "PTDefinitions.h"
#import "ProfileDescView.h"
#import "ProfileInfoView.h"
#import <UALogger.h>
#import "ProfileEditTableViewController.h"
#import "PTUtilities.h"
#import "UIImageView+WebCache.h"

#import "ProfileFollowCell.h"
#import "OtherProfileFollowCell.h"
#import "ProfileConnectCell.h"
#import "ProfilePlayCell.h"
#import "OtherProfilePlaylistCell.h"

#import "UserFollowViewController.h"
#import "UIViewController+Balancer.h"

#import "PTAppClientEngine.h"
#import "MusicListViewController.h"
#import "PlaylistItunesTableViewController.h"
#import "HotPlaylistViewController.h"

#import "YLRefresh.h"
#import "ProfileWeekPlayCell.h"

static NSInteger const ProfileHeadViewPageCount = 2;

@interface ProfileViewController ()<UIScrollViewDelegate,ProfileFollowCellDelegate,ProfilePlayCellDelegate,OtherProfileFollowCellDelegate,OtherProfilePlaylistCellDelegate,ProfileEditTableViewControllerDelegate, ProfileWeekPlayCellDelegate>{
    BOOL _isSystemUser;
    SelfUserProfile *_selfUserProfile;
    OtherUserProfile *_otherUserProfile;
}

//setting
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingBarItemButton;


//profile head view
@property (weak, nonatomic) IBOutlet UIView *profileHeadView;
@property (weak, nonatomic) IBOutlet UIImageView *profileHeadImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *profileScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *profilePageControl;

@property (strong, nonatomic) ProfileInfoView *profileInfoView;
@property (strong, nonatomic) ProfileDescView *profileDescView;

//data
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger nextPageIndex;

//table view data
@property (nonatomic, strong) NSArray *tableCells;
@property (strong, nonatomic) UIView *shadeView;

@end

@implementation ProfileViewController

@synthesize currentUser = _currentUser;

#pragma mark - 设置View
- (void)setupUIView{
    [self.profileScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame) * ProfileHeadViewPageCount, CGRectGetHeight(self.profileHeadView.frame))];
    self.profileInfoView = [[[NSBundle mainBundle]loadNibNamed:@"ProfileInfoView" owner:self options:nil] objectAtIndex:0];
    self.profileInfoView.frame = CGRectMake(0, 0,CGRectGetWidth(self.profileInfoView.frame), CGRectGetHeight(self.profileInfoView.frame));
    self.profileInfoView.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.profileDescView = [[[NSBundle mainBundle]loadNibNamed:@"ProfileDescView" owner:self options:nil] objectAtIndex:0];
    self.profileDescView.frame = CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.profileDescView.frame), CGRectGetHeight(self.profileDescView.frame));
    self.profileDescView.userDescLabel.numberOfLines = 0;
    
    [self.profileScrollView addSubview:self.profileInfoView];
    [self.profileScrollView addSubview:self.profileDescView];

    self.currentPageIndex = 0;

    [self.profilePageControl setNumberOfPages:ProfileHeadViewPageCount];
    [self.profilePageControl setCurrentPage:0];
    [self.profilePageControl addTarget:self
                                action:@selector(pageControlValueDidChanged:)
                      forControlEvents:UIControlEventValueChanged];
}

#pragma mark - 设置用户数据
//设置基础用户信息
- (void)setupBaseUserProfile:(UserAccount *)account{
    self.currentUser.nickname = account.nickname;
    self.currentUser.userAvatarImageLargeURL = account.userAvatarImageLargeURL;
    self.currentUser.userCoverURL = account.userCoverURL;
    self.currentUser.userSig = account.userSig;
    if (account.userCoverURL == nil) {
        self.profileHeadImageView.image = [UIImage imageNamed:@"BgProfile"];
    }else{
        [self.profileHeadImageView sd_setImageWithURL:account.userCoverURL placeholderImage:[UIImage imageNamed:@"BgProfile"]];
    }
    
    if (account.userAvatarImageLargeURL == nil) {
        [self.profileInfoView.avatarImageView setImage:[UIImage imageNamed:@"avatarImage"]];
    }else{
        [self.profileInfoView.avatarImageView sd_setImageWithURL:account.userAvatarImageLargeURL placeholderImage:[UIImage imageNamed:@"avatarImage"]];
    }
    
    [self.profileInfoView.nickNameLable setText:account.nickname];
    [self.profileDescView.userDescLabel setText:account.userSig];
}

//数据获取完成后更新用户信息
- (void)setupMyUserProfile:(SelfUserProfile *)myProfile{
    _selfUserProfile = myProfile;
    [self setupBaseUserProfile:_selfUserProfile.userAccount];
    [self.tableView reloadData];
}

- (void)setupUserProfile:(OtherUserProfile *)profile{
    _otherUserProfile = profile;
    [self setupBaseUserProfile:_otherUserProfile.userAccount];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self setUpBalancerView];
    
    self.title = PTNSLocalizedString(@"ProfileTitleMsgKey", nil);
    [self setupUIView];
    UserAccount *systemUser = [PTUtilities readLoginUser];
    NSMutableArray *temp = [NSMutableArray array];
    
    if (self.currentUser == nil) {
        self.navigationItem.leftBarButtonItem = self.settingBarItemButton;
    }
    
    if (self.currentUser == nil || [systemUser.userId integerValue] == [self.currentUser.userId integerValue]) {
        //self user
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"in" label:@"I_pro_in" value:nil];
        _isSystemUser = YES;
        self.currentUser = systemUser;
        [self.tableView registerNib:[UINib nibWithNibName:[ProfileFollowCell xibName] bundle:nil] forCellReuseIdentifier:[ProfileFollowCell reuseIdentifier]];
        [self.tableView registerNib:[UINib nibWithNibName:[ProfileConnectCell xibName] bundle:nil] forCellReuseIdentifier:[ProfileConnectCell reuseIdentifier]];
        [self.tableView registerNib:[UINib nibWithNibName:[ProfilePlayCell xibName] bundle:nil] forCellReuseIdentifier:[ProfilePlayCell reuseIdentifier]];
        [self.tableView registerNib:[UINib nibWithNibName:[ProfileWeekPlayCell xibName] bundle:nil] forCellReuseIdentifier:[ProfileWeekPlayCell reuseIdentifier]];
        [temp addObject:[NSNumber numberWithFloat:[ProfileFollowCell cellHeight]]];
        [temp addObject:[NSNumber numberWithFloat:[ProfileConnectCell cellHeight]]];
        [temp addObject:[NSNumber numberWithFloat:[ProfilePlayCell cellHeight]]];
        [temp addObject:[NSNumber numberWithFloat:[ProfileWeekPlayCell cellHeight]]];
    }else{
        //other user
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"h_pro" action:@"in" label:@"h_pro_in" value:nil];
        _isSystemUser = NO;
        [self.tableView registerNib:[UINib nibWithNibName:[OtherProfileFollowCell xibName] bundle:nil] forCellReuseIdentifier:[OtherProfileFollowCell reuseIdentifier]];
        [self.tableView registerNib:[UINib nibWithNibName:[OtherProfilePlaylistCell xibName] bundle:nil] forCellReuseIdentifier:[OtherProfilePlaylistCell reuseIdentifier]];
        
        [temp addObject:[NSNumber numberWithFloat:[OtherProfileFollowCell cellHeight]]];
        [temp addObject:[NSNumber numberWithFloat:[OtherProfilePlaylistCell cellHeight]]];
    }
    
    
    self.tableCells = [temp copy];
    
    [self setupBaseUserProfile:self.currentUser];
    [self setupRefresh];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_isSystemUser) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"out" label:@"I_pro_out" value:nil];
    } else {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"h_pro" action:@"out" label:@"h_pro_out" value:nil];
    }
}

- (void)setupRefresh{
    [self.tableView addHeaderWithTarget:self action:@selector(dropProfileViewDidBeginRefreshing:) dateKey:[NSString stringWithFormat:@"user-profile%@",self.currentUser.userId]];

    if ([PTUtilities isNetWorkConnect]) {
        [self.tableView headerBeginRefreshing];
    }else{
        if (_isSystemUser) {
            SelfUserProfile *selfProfile = [PTUtilities readMyProfile];
            [self setupMyUserProfile:selfProfile];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.tableCells count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [self.tableCells count];
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [[self.tableCells objectAtIndex:indexPath.section] floatValue];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([self.tableCells count]>2) {
        //self
        if (indexPath.section==0) {
            ProfileFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfileFollowCell reuseIdentifier] forIndexPath:indexPath];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:[ProfileFollowCell reuseIdentifier] owner:self options:nil] lastObject];
            }
            if (_selfUserProfile) {
                cell.followCountLabel.text = [_selfUserProfile.userAccount.userFolowCount stringValue];
                cell.followedCountLabel.text = [_selfUserProfile.userAccount.userFolowedCount stringValue];
            }else{
                cell.followCountLabel.text = [self.currentUser.userFolowCount stringValue];
                cell.followedCountLabel.text = [self.currentUser.userFolowedCount stringValue];
            }
            cell.delegate = self;
            return cell;
        }else if (indexPath.section == 1){
            ProfileConnectCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfileConnectCell reuseIdentifier] forIndexPath:indexPath];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:[ProfileConnectCell reuseIdentifier] owner:self options:nil] lastObject];
            }
            cell.connectLabel.text = PTNSLocalizedString(@"profileConnectServiceMsgKey", nil);
            
            return cell;
        }else {
            
            
            if (indexPath.section==2) {
                ProfilePlayCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfilePlayCell reuseIdentifier] forIndexPath:indexPath];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:[ProfilePlayCell reuseIdentifier] owner:self options:nil] lastObject];
                }
                cell.cellType = ProfilePlayCellTypeRecent;
                cell.musics = _selfUserProfile.recentArray;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                return cell;
            }else{
                ProfileWeekPlayCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfileWeekPlayCell reuseIdentifier] forIndexPath:indexPath];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:[ProfileWeekPlayCell reuseIdentifier] owner:self options:nil] lastObject];
                }
                cell.cellType = ProfilePlayCellTypeWeekRecent;
                cell.musics = _selfUserProfile.recentWeekArray;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                return cell;
            }

            
        }
    }else{
        if (indexPath.section==0) {
            OtherProfileFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:[OtherProfileFollowCell reuseIdentifier] forIndexPath:indexPath];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:[OtherProfileFollowCell reuseIdentifier] owner:self options:nil] lastObject];
            }
            
            if (_otherUserProfile) {
                cell.followCountLabel.text = [_otherUserProfile.userAccount.userFolowCount stringValue];
                cell.followedCountLabel.text = [_otherUserProfile.userAccount.userFolowedCount stringValue];
                cell.followed = _otherUserProfile.isFollowed;
            }else{
                cell.followCountLabel.text = [self.currentUser.userFolowCount stringValue];
                cell.followedCountLabel.text = [self.currentUser.userFolowedCount stringValue];
                cell.followed = NO;
            }
            cell.delegate = self;
            
            return cell;
        }else{
            OtherProfilePlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:[OtherProfilePlaylistCell reuseIdentifier] forIndexPath:indexPath];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:[OtherProfilePlaylistCell reuseIdentifier] owner:self options:nil] lastObject];
            }
            cell.feedPlaylists = _otherUserProfile.feedPlaylists;
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSystemUser && indexPath.section == 1) {
        //设置界面
        [self performSegueWithIdentifier:@"showConnectService" sender:nil];
    }
    
}

#pragma mark - Cell Delegate 
#pragma mark - ProfileFollowCellDelegate
- (void)sysFollowClickAction:(ProfileFollowCell *)cell{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"Click_I_pro" label:@"Follow_v" value:nil];
    [self performSegueWithIdentifier:@"showUserFollow" sender:@"Follow"];
}

- (void)sysFollowedClickAction:(ProfileFollowCell *)cell{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"Click_I_pro" label:@"Followed_v" value:nil];
    [self performSegueWithIdentifier:@"showUserFollowed" sender:@"Followed"];
}

#pragma mark - ProfilePlayCellDelegate
- (void)profilePlayCell:(ProfilePlayCell *)cell didShowMore:(ProfilePlayCellType)type{
    if (type == ProfilePlayCellTypeRecent) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"Click_I_pro" label:@"recent_play_more" value:nil];
    } else if (type == ProfilePlayCellTypeWeekRecent) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"Click_I_pro" label:@"Most_play_more" value:nil];
    }
    [self performSegueWithIdentifier:@"showUserRecent" sender:cell];
}

#pragma mark - OtherProfileFollowCellDelegate
- (void)otherFollowClickAction:(OtherProfileFollowCell *)cell{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"h_pro" action:@"Click_h_pro" label:@"h_Follow_v" value:nil];
    [self performSegueWithIdentifier:@"showUserFollow" sender:@"OtherFollow"];
}
- (void)otherFollowedClickAction:(OtherProfileFollowCell *)cell{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"h_pro" action:@"Click_h_pro" label:@"h_Followed_v" value:nil];
    [self performSegueWithIdentifier:@"showUserFollowed" sender:@"OtherFollowed"];
}

- (void)unFollowClickAction:(OtherProfileFollowCell *)cell{
    //不关注
    UserAccount *userAccount = [PTUtilities readLoginUser];
    [SVProgressHUD show];
     __weak typeof(self) weakSelf = self;
    [[PTAppClientEngine sharedClient] userFollowActWithUserId:userAccount.userId
                                                        token:userAccount.userToken
                                                  otherUserId:self.currentUser.userId
                                                      actType:UserFollowActDel
                                                   completion:^(NSError *error) {
        if (error) {
            cell.followed = YES;
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }else{
            cell.followed = NO;
            __strong typeof(self) strongSelf = weakSelf;
            int currentFollowedCount = [_otherUserProfile.userAccount.userFolowedCount intValue];
            _otherUserProfile.userAccount.userFolowedCount = [NSNumber numberWithInt:(currentFollowedCount-1)];
            _otherUserProfile.followed = NO;
            [strongSelf setupUserProfile:_otherUserProfile];
            
            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"CancelFollowOkMsgKey", nil)];
        }
    }];
}
- (void)addFollowClickAction:(OtherProfileFollowCell *)cell{
    //加关注
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"h_pro" action:@"Click_h_pro" label:@"h_Followeing" value:nil];
    UserAccount *userAccount = [PTUtilities readLoginUser];
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[PTAppClientEngine sharedClient] userFollowActWithUserId:userAccount.userId
                                                        token:userAccount.userToken
                                                  otherUserId:self.currentUser.userId
                                                      actType:UserFollowActAdd
                                                   completion:^(NSError *error) {
        if (error) {
            cell.followed = NO;
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }else{
            cell.followed = YES;
            __strong typeof(self) strongSelf = weakSelf;
            int currentFollowedCount = [_otherUserProfile.userAccount.userFolowedCount intValue];
            _otherUserProfile.userAccount.userFolowedCount = [NSNumber numberWithInt:(currentFollowedCount+1)];
            _otherUserProfile.followed = YES;
            [strongSelf setupUserProfile:_otherUserProfile];
            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"FollowOkMsgKey", nil)];
        }
    }];
}

#pragma mark - OtherProfilePlayCellDelegate

- (void)profilePlaylistCell:(OtherProfilePlaylistCell *)cell playlistDetail:(PlaylistObj *)playlist{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"h_pro" action:@"Click_h_pro" label:@"feed_playlist" value:nil];
    UALog(@"playlist...%@",playlist);
    PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
    playlistItunesVC.listId = [NSString stringWithFormat:@"%@",playlist.listId];
    [self.navigationController pushViewController:playlistItunesVC animated:YES];
}

- (void)profilePlaylistCellShowMore:(OtherProfilePlaylistCell *)cell{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"h_pro" action:@"Click_h_pro" label:@"feed_playlist_more" value:nil];
    [self performSegueWithIdentifier:@"profileShowPlaylists" sender:cell];
}
#pragma mark - Action

- (IBAction)pageControlValueDidChanged:(UIPageControl *)sender{
    [self.profileScrollView setContentOffset:CGPointMake(sender.currentPage * CGRectGetWidth(self.view.frame),0)
                             animated:YES];
}

- (IBAction)editUserProfileAction:(UITapGestureRecognizer *)sender {
    UserAccount *sysUser = [PTUtilities readLoginUser];
    if ([sysUser.userId intValue] == [self.currentUser.userId intValue]) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"I_pro" action:@"double_click_i" label:@"i_view/edit" value:nil];
        [self performSegueWithIdentifier:@"profileEditIdentifier" sender:sender];
    }
}


#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.profileScrollView == scrollView) {
        float scrollingPosition = scrollView.contentOffset.x / CGRectGetWidth(self.profileHeadView.frame);

        int currentPage = (int)scrollingPosition;
        if (currentPage >1) {
            self.currentPageIndex = 1;
        }else if (currentPage < 0) {
            self.currentPageIndex = 0;
        }else{
            self.currentPageIndex = (int)scrollingPosition;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.profileScrollView == scrollView) {
        [self.profilePageControl setCurrentPage:self.currentPageIndex];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"profileEditIdentifier"]) {
        ProfileEditTableViewController *profileEdit = segue.destinationViewController;
        profileEdit.currentAccount = self.currentUser;
        profileEdit.imageHeight = self.profileHeadView.frame.size.height;
        profileEdit.delegate = self;
    }else if([segue.identifier isEqualToString:@"showUserFollow"]){
        UserFollowViewController *followVC = segue.destinationViewController;
        followVC.title = PTNSLocalizedString(@"FollowTitleMsgKey", nil);
        followVC.followType = UserFollowTypeFollow;
        followVC.userId = self.currentUser.userId;
    }else if ([segue.identifier isEqualToString:@"showUserFollowed"]){
        UserFollowViewController *followedVC = segue.destinationViewController;
        followedVC.title = PTNSLocalizedString(@"FollowedTitleMsgKey", nil);
        followedVC.followType = UserFollowTypeFollowed;
        followedVC.userId = self.currentUser.userId;
    }else if ([segue.identifier isEqualToString:@"showUserRecent"]){
        MusicListViewController *musicList = segue.destinationViewController;
        ProfilePlayCell *playCell = (ProfilePlayCell *)sender;
        if (playCell.cellType == ProfilePlayCellTypeRecent) {
            musicList.title = PTNSLocalizedString(@"RecentPlayTitleMsgKey", nil);
        }else{
            musicList.title = PTNSLocalizedString(@"RecentWeekPlayTitleMsgKey", nil);
        }
        musicList.musics = playCell.musics;
    }else if ([segue.identifier isEqualToString:@"profileShowPlaylists"]){
        HotPlaylistViewController *hotPlaylistVc = segue.destinationViewController;
        hotPlaylistVc.otherUserId = self.currentUser.userId;
        hotPlaylistVc.title = PTNSLocalizedString(@"FeededPlaylistTitleMsgKey", nil);
    }
}

#pragma mark - ProfileEditTableViewControllerDelegate

- (void)didProfileUpdate:(ProfileEditTableViewController *)controller{
    [self.tableView headerBeginRefreshing];
}

#pragma mark - refreshing

- (void)dropProfileViewDidBeginRefreshing:(id)refreshControl
{
    if(![PTUtilities isNetWorkConnect]){
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil)];
        [self.tableView headerEndRefreshing];
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (_isSystemUser) {
        [[PTAppClientEngine sharedClient] findSelfProfileWithUserId:self.currentUser.userId
                                                              token:self.currentUser.userToken
                                                         completion:^(SelfUserProfile *user, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf finishRefreshControl];
            if (error) {
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }else{
                [strongSelf setupMyUserProfile:user];
            }
        }];
    }else{
        UserAccount *sysUser = [PTUtilities readLoginUser];
        [[PTAppClientEngine sharedClient] findUserProfileWithUserId:sysUser.userId
                                                              token:sysUser.userToken
                                                        otherUserId:self.currentUser.userId
                                                         completion:^(OtherUserProfile *user, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf finishRefreshControl];
            if (error) {
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }else{
                [strongSelf setupUserProfile:user];
            }
        }];
    }
}

- (void)finishRefreshControl
{
    [self.tableView headerEndRefreshing];
}


@end
