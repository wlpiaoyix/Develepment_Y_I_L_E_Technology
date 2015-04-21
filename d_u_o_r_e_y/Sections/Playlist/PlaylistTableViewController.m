//
//  PlaylistTableViewController.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistTableViewController.h"
#import "PlaylistViewTableViewCell.h"
#import "REMenu.h"
#import "NewPlaylistSetNameViewController.h"
#import "ImportTableViewController.h"
#import "PlaylistItunesTableViewController.h"
#import <SVProgressHUD.h>
#import "PTAppClientEngine.h"
#import "PTDefinitions.h"
#import "PTConstant.h"
#import "PlaylistObj.h"
#import "UserAccount.h"
#import "SongObj.h"
#import "YLRefresh.h"
#import "UIViewController+Balancer.h"
#import "UIImageView+WebCache.h"

#define PLAYLIST_CELL @"playlistCell"

@interface PlaylistTableViewController ()<REMenuDelegate>{
    int _pageCount;
    __block BOOL isLoading;
    SWTableViewCell *_aCell;
}

@property ( nonatomic) NSMutableArray *playlistArr;
@property (strong, readwrite, nonatomic) REMenu *menu;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) UIView *noContentView;

@end

@implementation PlaylistTableViewController

- (UserAccount *)userAccount{
    return [PTUtilities readLoginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self setUpBalancerView];
    [self addMenuView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _pageCount=1;
    [self setupRefresh];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man" action:@"in" label:@"P_man_in" value:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man" action:@"out" label:@"P_man_out" value:nil];
}

-(UIView *)noContentView
{
    if (!_noContentView)
    {
        _noContentView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_noContentView];
        [_noContentView setBackgroundColor:[UIColor whiteColor]];
        UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, [UIScreen mainScreen].bounds.size.width, 187)];
        [_noContentView addSubview:centerView];
        centerView.center = CGPointMake(self.view.center.x, centerView.center.y);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 113, 127)];
        [imageView setImage:[UIImage imageNamed:@"IconMusicB"]];
        [centerView addSubview:imageView];
        imageView.center = CGPointMake(centerView.center.x, imageView.center.y);
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 12)];
        textLabel.text = PTNSLocalizedString(@"NoPlaylistDataLableMsgKey", nil);
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor colorWithRed:166.0f/255.0f green:166.0f/255.0f blue:166.0f/255.0f alpha:1.0f];
        [centerView addSubview:textLabel];
        [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        textLabel.center = CGPointMake(centerView.center.x, imageView.frame.size.height + 21);
    }
    return _noContentView;
}


- (void)addMenuView{
//    __typeof (self) __weak weakSelf = self;
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:PTNSLocalizedString(@"MenuImportPlaylistMsgKey", nil)
                                                    subtitle:nil
                                                       image:[UIImage imageNamed:@"import_Image"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          UALog(@"Item: %@", item);
                                                              [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_add" action:@"Click_import" label:@"import" value:nil];
                                                          ImportTableViewController *importVC = [self.storyboard instantiateViewControllerWithIdentifier:@"importVC"];
                                                          importVC.hidesBottomBarWhenPushed = YES;
                                                          [self.navigationController pushViewController:importVC animated:YES];
                                                      }];
    [homeItem setFont: [UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    [homeItem setTextColor:[UIColor colorWithWhite:0.290 alpha:1.000]];
    REMenuItem *exploreItem = [[REMenuItem alloc] initWithTitle:PTNSLocalizedString(@"MenuNewPlaylistMsgKey", nil)
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"new_image"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             UALog(@"Item: %@", item);
                                                             [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_add" action:@"Click_new" label:@"new" value:nil];
                                                             NewPlaylistSetNameViewController *newPlaylistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newPlaylistVC"];
                                                             newPlaylistVC.hidesBottomBarWhenPushed = YES;
                                                             [self.navigationController pushViewController:newPlaylistVC animated:YES];
                                                         }];
    [exploreItem setFont: [UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    [exploreItem setTextColor:[UIColor colorWithWhite:0.290 alpha:1.000]];
    self.menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem]];
    self.menu.delegate = self;
    
    [self.menu setClosePreparationBlock:^{
        UALog(@"Menu will close");
    }];
    
    [self.menu setCloseCompletionHandler:^{
        UALog(@"Menu did close");
    }];
}

#pragma mark - REMenu Delegate Methods

-(void)willOpenMenu:(REMenu *)menu
{
    UALog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}

-(void)didOpenMenu:(REMenu *)menu
{
    UALog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}

-(void)willCloseMenu:(REMenu *)menu
{
    UALog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}

-(void)didCloseMenu:(REMenu *)menu
{
    UALog(@"Delegate method: %@", NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadPlaylistData
{
    if (!isLoading && ![_playlistArr count]) {
        self.noContentView.hidden = YES;
        [self.tableView headerBeginRefreshing];
    }
}

-(void)reloadData
{
    if ([_playlistArr count] == 0) {
        self.noContentView.hidden = NO;
        [self.view bringSubviewToFront:_noContentView];
    }
    else
    {
        self.noContentView.hidden = YES;
    }
    [self.tableView reloadData];
}

-(void)decideShowNoContentView
{
    if ([_playlistArr count] == 0) {
        self.noContentView.hidden = NO;
        [self.view bringSubviewToFront:_noContentView];
    }
    else
    {
        self.noContentView.hidden = YES;
    }
}

#pragma 开始刷新函数
- (void)setupRefresh{
    [self.tableView addHeaderWithTarget:self action:@selector(dropViewDidBeginRefreshing:) dateKey:@"playlist"];
    if ([PTUtilities isNetWorkConnect] && [PTUtilities shouldRefreshPlaylist]) {
        [self.tableView headerBeginRefreshing];
    }else{
       _playlistArr =  [PTUtilities unarchiveObjectWithName:@"LastLoadPlaylist"];
        [self.tableView reloadData];
    }
}

#pragma mark - refreshing
- (void)dropViewDidBeginRefreshing:(id)refreshControl
{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [self userAccount];
    isLoading = YES;
    [[PTAppClientEngine sharedClient] getPlaylistAndFollowlistWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                   token:user.userToken
                                                                    page:1
                                                              completion:^(NSArray *playlists, NSError *error) {
                                                                   __strong typeof(self) strongSelf = weakSelf;
                                                                  [strongSelf.tableView headerEndRefreshing];
                                                                  if (!error) {
                                                                      if ([playlists count]>0) {
                                                                          _playlistArr=(NSMutableArray *)playlists;
                                                                          _pageCount=2;
                                                                          [PTUtilities archiveObject:playlists withName:@"LastLoadPlaylist"];
                                                                          [strongSelf.tableView removeFooter];
                                                                          [strongSelf.tableView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                                      }else{
                                                                          if (_playlistArr) {
                                                                              [_playlistArr removeAllObjects];
                                                                          }
                                                                      }
                                                                      [strongSelf.tableView reloadData];
                                                                      isLoading = NO;
                                                                      [PTUtilities setNeedRefrshPlaylist:NO];
                                                                  }else{
                                                                      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                      isLoading = NO;
                                                                  }
                                                                  [strongSelf decideShowNoContentView];
                                                              }];
}

- (void)upViewDidBeginRefreshingFollow:(id)sender{
    __weak typeof(self) weakSelf = self;
    //获取数据的
    isLoading = YES;
    UserAccount *user = [self userAccount];
    [[PTAppClientEngine sharedClient] getPlaylistAndFollowlistWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                   token:user.userToken
                                                                    page:_pageCount
                                                              completion:^(NSArray *playlists, NSError *error) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                  if (!error) {
                                                                      if ([playlists count]>0) {
                                                                          [_playlistArr addObjectsFromArray:playlists];
                                                                          [strongSelf.tableView reloadData];
                                                                          _pageCount++;
                                                                          [PTUtilities archiveObject:playlists withName:@"LastLoadPlaylist"];
                                                                          [strongSelf.tableView endLoadMoreRefreshing];
                                                                      }else{
                                                                          [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                          [strongSelf.tableView endMoreOverWithMessage:@""];
                                                                          [strongSelf.tableView removeFooter];
                                                                      }
                                                                  }else{
                                                                      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                  }
                                                                  isLoading = NO;
                                                                  [strongSelf decideShowNoContentView];
                                                              }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_playlistArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLAYLIST_CELL
                                                                      forIndexPath:indexPath];
    if (cell==nil) {
        cell = [[PlaylistViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:PLAYLIST_CELL];
    }
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    PlaylistObj *playlist = [_playlistArr objectAtIndex:indexPath.row];
    
    NSString *listName = playlist.listName;
    NSString *totaleNumStr = [NSString stringWithFormat:PTNSLocalizedString(@"PlaylistSectionCountMsgKey", nil),[playlist.totalNum intValue]];
    NSString *listStr = [NSString stringWithFormat:PTNSLocalizedString(@"PlaylistCellCountMsgKey", nil),listName,[playlist.totalNum intValue]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:listStr];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"HelveticaNeue-light" size:14]
                       range:NSMakeRange([listStr length]-[totaleNumStr length], [totaleNumStr length])];
    [cell.countLabel setAttributedText:attrString];
    
    if (![PTUtilities isEmptyOrNull:playlist.listIcon]) {
        [cell.mainIamgeView sd_setImageWithURL:[NSURL URLWithString:playlist.listIcon]
                              placeholderImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];

    }else{
        [cell.mainIamgeView setImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];

    }
    [cell.mainIamgeView setContentMode:UIViewContentModeScaleAspectFill];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
    playlistItunesVC.playlistObj = ((PlaylistObj *)[_playlistArr objectAtIndex:indexPath.row]);
    playlistItunesVC.listId = [NSString stringWithFormat:@"%@",((PlaylistObj *)[_playlistArr objectAtIndex:indexPath.row]).listId];
    playlistItunesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:playlistItunesVC animated:YES];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man" action:@"Click_playlist" label:@"p_detail" value:nil];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_button"]];
    
    for (SWUtilityButton *button in rightUtilityButtons) {
        button.normolBackgroudColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f];
        button.highlitedBackgroudColor = [UIColor colorWithRed:208/255.0f green:2/255.0f blue:27/255.0f alpha:1.0f];
    }
    
    return rightUtilityButtons;
}

#pragma mark - header and footer

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

#pragma mark - button action

- (IBAction)addButtonAction:(id)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man" action:@"Click_add" label:@"add" value:nil];
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];
}

- (IBAction)playButtonAction:(id)sender {
    
}

- (IBAction)topViewAddButtonAction:(id)sender {
    UALog(@"new playlist");
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            UALog(@"utility buttons closed");
            break;
        case 1:
            UALog(@"left utility buttons open");
            break;
        case 2:
            UALog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            UALog(@"left button 0 was pressed");
            break;
        case 1:
            UALog(@"left button 1 was pressed");
            break;
        case 2:
            UALog(@"left button 2 was pressed");
            break;
        case 3:
            UALog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PTNSLocalizedString(@"PlaylistRemoveAlertMsgKey" ,nil)
                                                            message:PTNSLocalizedString(@"PlaylistCancelFeedMsgKey" ,nil)
                                                           delegate:self
                                                  cancelButtonTitle:PTNSLocalizedString(@"PlaylistRemoveCancelMsgKey" ,nil)
                                                  otherButtonTitles:PTNSLocalizedString(@"PlaylistRemoveRemoveMsgKey" ,nil), nil];
            [alert show];
            _aCell = cell;
            break;
        }
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
//            [_testArray[cellIndexPath.section] removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:_aCell];
        UserAccount *user = [self userAccount];
        [SVProgressHUD showWithStatus:PTNSLocalizedString(@"PlaylistUnsubscribeLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
        __weak typeof(self) weakSelf = self;
        [[PTAppClientEngine sharedClient] playlistFlowWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                          listId:[NSString stringWithFormat:@"%@",((PlaylistObj*)[_playlistArr objectAtIndex:cellIndexPath.row]).listId]
                                                           token:user.userToken
                                                          action:@"del"
                                                      completion:^(PlaylistObj *playlist,NSError *error){
                                                          __strong typeof(self) strongSelf = weakSelf;
                                                          if (!error) {
                                                              [strongSelf dropViewDidBeginRefreshing:nil];
                                                              [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"UnsubscribeOkMsgKey", nil)];
                                                              [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man" action:@"slide_cancel" label:@"cancel_playlist" value:nil];
                                                          }else{
                                                              [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                          }
                                                      }];
        [_aCell hideUtilityButtonsAnimated:YES];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

@end
