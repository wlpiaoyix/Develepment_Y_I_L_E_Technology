//
//  ActivityViewController.m
//  Acticity
//
//  Created by ice on 14/11/27.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityTableViewCell.h"
#import "ActivityFollowTableViewCell.h"
#import "UIViewController+Balancer.h"

#import "UserAccount.h"
#import "PTAppClientEngine.h"
#import "PTUtilities.h"

#import "AddMusicToPlaylistViewController.h"
#import "PlaylistItunesTableViewController.h"
#import "ProfileViewController.h"

#import "YLAudioPlayer.h"
#import "YLRefresh.h"

@interface ActivityViewController ()<UITableViewDelegate,UITableViewDataSource,ActivityTableCellDelegate,ActivityFollowTableViewCellDelegate>
{
   __block NSInteger dataPage;
    BOOL isPullingHeaderView;
   __block BOOL isLoading;
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,weak) IBOutlet UIView *noContentView;
@property (nonatomic,weak) IBOutlet UITableView *activityTableView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@end

@implementation ActivityViewController

#pragma -mark life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    
    [self setUpBalancerView];
    [self configTableView];
    self.noDataLabel.text = PTNSLocalizedString(@"noActivityDataMsgKey", nil);
    self.dataArray = [NSMutableArray array];
    self.noContentView.hidden = YES;
    [self registeTableCell];
//    [self.activityTableView headerBeginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"out" label:@"D_act_out" value:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"in" label:@"D_act_in" value:nil];
}
#pragma -mark pravite methods

-(void)configTableView
{
    dataPage = 1;
    [self.activityTableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    if ([PTUtilities isNetWorkConnect]) {
        [self.activityTableView headerBeginRefreshing];
    }
    else
    {
        [self decideShowNoContentView];
    }
    self.activityTableView.showsVerticalScrollIndicator = NO;

}

-(void)headerRereshing
{
    // 每次下拉刷新，重置footer
    [self.activityTableView removeFooter];
    [self.activityTableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    isPullingHeaderView = YES;
    dataPage = 1;
    [self loadActiveData:dataPage];
}

-(void)footerRereshing
{
    isPullingHeaderView = NO;
    [self loadActiveData:dataPage];
}

-(void)activityTableReloadData
{
    [self.activityTableView reloadData];
    if (isPullingHeaderView) {
        [self.activityTableView headerEndRefreshing];
    }
    isLoading = NO;
}

-(void)reloadActivityData
{
    if (![self.dataArray count] && !isLoading) {
        self.noContentView.hidden = YES;
        [self.activityTableView headerBeginRefreshing];
    }
}

- (UserAccount *)userAccount{
    return [PTUtilities unarchiveObjectWithName:@"me"];
}

-(void)loadActiveData:(NSInteger)page
{
//    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"loading...", nil)
//                         maskType:SVProgressHUDMaskTypeBlack];
    if (![PTUtilities isNetWorkConnect])
    {
        [self decideShowNoContentView];
        [self.activityTableView headerEndRefreshing];
        [self.activityTableView endMoreOverWithMessage:@""];
        return;
    }
    isLoading = YES;
    UserAccount *user = [self userAccount];
    __weak typeof(self) wSelf = self;
    [[PTAppClientEngine sharedClient] activityWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                   token:user.userToken
                                                                    page:dataPage
                                                              completion:^(NSArray *activity,NSError *error) {
                                                                  __strong typeof(self) sSelf = wSelf;
                                                                  if (!error)
                                                                  {
                                                                      if (dataPage == 1) {
                                                                          [sSelf.dataArray removeAllObjects];
                                                                      }
                                                                      [sSelf.dataArray addObjectsFromArray:activity];
                                                                      [sSelf activityTableReloadData];
                                                                      if ([activity count] > 0) {
                                                                          if (!isPullingHeaderView) {
                                                                              [sSelf.activityTableView endLoadMoreRefreshing];
                                                                          }
                                                                          dataPage++;
                                                                      } else {
                                                                          if (!isPullingHeaderView) {
                                                                              [sSelf.activityTableView endMoreOverWithMessage:@""];
                                                                              [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                          }
                                                                      }
                                                                      isLoading = NO;
//                                                                      [SVProgressHUD dismiss];
                                                                  }else{
                                                                      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                  }
                                                                  [sSelf decideShowNoContentView];
                                                                  isLoading = NO;
                                                              }];
}

-(void)registeTableCell
{
    [self.activityTableView registerNib:[UINib nibWithNibName:NSStringFromClass([ActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ActivityTableViewCell class])];
    [self.activityTableView registerNib:[UINib nibWithNibName:NSStringFromClass([ActivityFollowTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ActivityFollowTableViewCell class])];
}

-(void)decideShowNoContentView
{
    if (isPullingHeaderView) {
        [self.activityTableView headerEndRefreshing];
    }

    if ([_dataArray count]) {
        self.noContentView.hidden = YES;
        [self.view sendSubviewToBack:self.noContentView];
    }
    else
    {
        self.noContentView.hidden = NO;
        [self.view bringSubviewToFront:self.noContentView];
    }
}


#pragma -mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityObj *obj = [_dataArray objectAtIndex:indexPath.row];
    if ([obj.activityType integerValue] == ActivityTypeFollowSomebody) {
        ActivityFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ActivityFollowTableViewCell class])];
        [cell loadCellData:obj];
        cell.followDelegate = self;
        return cell;
    }
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ActivityTableViewCell class])];
    [cell loadCellData:obj];
    cell.cellDelegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityObj *obj = [_dataArray objectAtIndex:indexPath.row];
    if ([obj.activityType integerValue] == ActivityTypeFollowSomebody) {
        return 72.0f;
    }
    return 162.0f;
}

#pragma -mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityObj *obj = [_dataArray objectAtIndex:indexPath.row];
    if ([obj.activityType integerValue] == ActivityTypeFollowPlayList  || [obj.activityType integerValue] == ActivityTypeCommentPlayList)
    {
        //跳转到歌单详细页面
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"D_act_click" label:@"playlist" value:nil];
        PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
        UALog(@"====%@",obj.playList.listId);
        playlistItunesVC.listId = [NSString stringWithFormat:@"%@",obj.playList.listId];
        playlistItunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:playlistItunesVC animated:YES];
    }
    else if ([obj.activityType integerValue] == ActivityTypeFollowSomebody)
    {
        if (obj.user)
        {
           [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"D_act_click" label:@"From" value:nil];
            ProfileViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            profile.currentUser = obj.user;
            profile.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:profile animated:YES];
        }
    }
}

#pragma -mark ActivityCellDelegate

-(void)activityCellAddSong:(ActivityObj *)obj
{
    if (obj.music) {
        AddMusicToPlaylistViewController *addMusicToPlaylist = [self.storyboard instantiateViewControllerWithIdentifier:@"addMusicToPlaylistVC"];
        addMusicToPlaylist.playlistObjDic=(NSMutableDictionary *)[MTLJSONAdapter JSONDictionaryFromModel:obj.music];
//        UINavigationController *aNavRegist = [[UINavigationController alloc] initWithRootViewController:addMusicToPlaylist];
//        [self presentViewController:aNavRegist animated:YES completion:nil];
        addMusicToPlaylist.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:addMusicToPlaylist animated:YES];
    }
}

-(void)activityCellPlaySong:(ActivityObj *)obj
{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"D_act_click" label:@"songs_paly" value:nil];
    if (obj.music)
    {
        if ([[YLAudioPlayer sharedAudioPlayer].currentPlayMusic isEqual:obj.music])
        {
            if ([YLAudioPlayer sharedAudioPlayer].isPlaying) {
                [[YLAudioPlayer sharedAudioPlayer] pause];
            }
            else
            {
                [[YLAudioPlayer sharedAudioPlayer] play];
            }
            
        }
        else
            [[YLAudioPlayer sharedAudioPlayer] playCurrentTrack:obj.music];
    }
}

-(void)activityCellClickedUser:(UserAccount *)user
{
    if (user)
    {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"D_act_click" label:@"people" value:nil];
        ProfileViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profile.currentUser = user;
        profile.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profile animated:YES];
    }
}
-(void)activityCellClickPlayList:(PlaylistObj *)playList
{
    if (playList) {
        //跳转到歌单详细页面
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"D_act_click" label:@"playlist" value:nil];
        PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
        playlistItunesVC.listId = [NSString stringWithFormat:@"%@",playList.listId];
        playlistItunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:playlistItunesVC animated:YES];

    }
}

#pragma -mark ActivityFollowDelegate

-(void)activityFollowTableViewCellSelectUser:(ActivityObj *)obj
{
    if (obj.user)
    {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"D_act_click" label:@"From" value:nil];
        ProfileViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profile.currentUser = obj.user;
        profile.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profile animated:YES];
    }
}

-(void)activityFollowTableViewCellSelectFollowUser:(ActivityObj *)obj
{
    if (obj.followUser)
    {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"D_act" action:@"D_act_click" label:@"people" value:nil];
        ProfileViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profile.currentUser = obj.followUser;
        profile.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profile animated:YES];
    }
}
@end
