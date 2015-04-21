//
//  PlaylistItunesTableViewController.m
//  Duorey
//
//  Created by lixu on 14/11/18.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistItunesTableViewController.h"
#import "PlaylistItunesTableViewCell.h"
#import "AddMusicToPlaylistViewController.h"
#import "UIImageView+WebCache.h"
#import "SWTableViewCell.h"
#import "PTAppClientEngine.h"
#import "PTConstant.h"
#import "Music.h"
#import "UserAccount.h"
#import "YLAudioPlayer.h"
#import "PlaylistSearchViewController.h"
#import "PlaylistInfoTableViewController.h"
#import "PlaylistDetail.h"
#import "PubPlaylist.h"
#import "UIView+WebCacheOperation.h"
#import "UIViewController+Balancer.h"
#import "YLRefresh.h"
#import "LikeAndFeederTableViewController.h"
#import "ProfileViewController.h"
#import "PTTheme.h"
#import "CBAutoScrollLabel.h"

static NSString *playlistItunesCell = @"playlistItunesCell";

@interface PlaylistItunesTableViewController ()<PlaylistItunesTableViewCellDelegate,UIActionSheetDelegate>{
    int _isDing;
    int _isFlow;
    int _isLikerCount;
    int _isFlowCount;
    int _pageCount;
    int _deleteCount;
    BOOL _isPlayingAll;
    BOOL _isFristPlayAll;
    PlaylistItunesTableViewCell *currentSelectCell;
}

@property (weak,nonatomic) PlaylistItunesTableViewCell *aCell;
@property (nonatomic) NSMutableArray *listArr;
@property (weak, nonatomic) IBOutlet UIImageView *countBgImageView;

@end

@implementation PlaylistItunesTableViewController
@synthesize delegate=delegate;

- (UIImage *)countBgImageWithName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0)];
}

- (UserAccount *)userAccount{
    return [PTUtilities readLoginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBackButtonItemTitleByEmpty];
    [self setUpBalancerView];
    _deleteCount=0;
    [PTThemeManager customizeWhiteHeadView:self.topView];
    addNotificationObserver(STOP_PLAYLIST_PLAY_ALL_START, self, @selector(reSetAllPlayButtonState), nil);
    addNotificationObserver(PlaylistLastMusicPlayed, self, @selector(playListLastMusicPlayed:), nil);
}

- (void)playListLastMusicPlayed:(NSNotification *)notif {
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *listIdStr = [userDefaults objectForKey:@"playlistDetailPageAllPlayListId"];
    if ([listIdStr isEqualToString:[NSString stringWithFormat:@"playlistDetailPlay%@",self.listId]]) {
        NSString *startStr = [userDefaults objectForKey:listIdStr];
        if ([startStr isEqualToString:@"on"]) {
            _isPlayingAll = YES;
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
        }else{
            _isPlayingAll = NO;
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
        }
    }else{
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
    }
//    [_countBgImageView setImage:[self countBgImageWithName:@"count_bg"]];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"in" label:@"P_man_de_in" value:nil];
    _listArr = [[NSMutableArray alloc] init];
    _pageCount=1;
    
    [self dropViewDidBeginRefreshing:nil];
//    [self.tableView addHeaderWithTarget:self action:@selector(dropViewDidBeginRefreshing:) dateKey:@"playlist"];
//    [self.tableView headerBeginRefreshing];
    
    UALog(@"current play list id: %@", [YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId);

    if ([YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId) {
        if ([[YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId isEqualToString:self.listId] && [YLAudioPlayer sharedAudioPlayer].isPlaying) {
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
        } else {
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
        }
    } else {
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.whereF isEqualToString:@"topView"]) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_manul_1" action:@"out" label:@"T_in_manul_1_out" value:nil];
    }
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"out" label:@"P_man_de_out" value:nil];
}

- (void)initUIValue{
    if (self.playlistObj) {
        //名字长了，显示不完，这个滚动显示
        CBAutoScrollLabel *playeListNameLabel = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        playeListNameLabel.text = self.playlistObj.listName;
        self.navigationItem.titleView = playeListNameLabel;
        
        self.headerCountLabel.text = [NSString stringWithFormat:@"%@",self.playlistObj.listenNum];
        if(![PTUtilities isEmptyOrNull:self.playlistObj.listIcon]){
            [self.topImageView sd_setImageWithURL:[NSURL URLWithString:self.playlistObj.listIcon]
                                 placeholderImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];
        }else{
            [self.topImageView setImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];
        }
        [self.topImageView setContentMode:UIViewContentModeScaleAspectFill];
        _isLikerCount=[self.playlistObj.likeNum intValue];
        _isFlowCount=[self.playlistObj.flowNum intValue];
        
        self.likerNameLabel.text = PTNSLocalizedString(@"PlaylistItunesLikerMsgKey", nil);
        self.feederNameLabel.text = PTNSLocalizedString(@"PlaylistItunesFeederMsgKey", nil);
        self.likerLabel.text = [NSString stringWithFormat:@"%d",_isLikerCount];
        self.feederLabel.text = [NSString stringWithFormat:@"%d",_isFlowCount];
    }
}

- (void)upViewDidBeginRefreshingFollow:(id)sender{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [self userAccount];
    [[PTAppClientEngine sharedClient] getOneListWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                     token:user.userToken
                                                    listId:self.listId
                                                      page:_pageCount
                                                completion:^(PubPlaylist *pubPlaylistObj,NSError *error){
                                                    __strong typeof(self) strongSelf = weakSelf;
                                                    if (!error) {
                                                        if ([pubPlaylistObj.allData count]>0) {
                                                            _pageCount++;
                                                            [_listArr addObjectsFromArray:pubPlaylistObj.allData];
                                                            [strongSelf.tableView endLoadMoreRefreshing];
                                                        }else{
                                                            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                            [strongSelf.tableView endMoreOverWithMessage:@""];
                                                        }
                                                        [self.tableView reloadData];
                                                    }else{
                                                        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                    }
                                                }];
}

- (void)dropViewDidBeginRefreshing:(id)refreshControl{
    _deleteCount=0;
//    __weak typeof(self) weakSelf = self;
    UserAccount *user = [self userAccount];
    [[PTAppClientEngine sharedClient] getOneListWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                     token:user.userToken
                                                    listId:self.listId
                                                      page:1
                                                completion:^(PubPlaylist *pubPlaylistObj,NSError *error){
//                                                    __strong typeof(self) strongSelf = weakSelf;
//                                                    [strongSelf.tableView headerEndRefreshing];
                                                    if (!error) {
                                                        if(pubPlaylistObj.playlistObj){
                                                            _isDing=pubPlaylistObj.isDing;
                                                            _isFlow=pubPlaylistObj.isFlow;
                                                            self.playlistObj=pubPlaylistObj.playlistObj;
                                                            NSString *isDingStr = pubPlaylistObj.isDing==0?@"like_no":@"like";
                                                            [self.goodButton setImage:[UIImage imageNamed:isDingStr] forState:UIControlStateNormal];
                                                            NSString *isFlowStr = pubPlaylistObj.isFlow==0?@"FEED_no":@"FEED";
                                                            [self.shareButton setImage:[UIImage imageNamed:isFlowStr] forState:UIControlStateNormal];
                                                            [self initUIValue];
                                                        }
                                                        if ([pubPlaylistObj.allData count]>0) {
                                                            _pageCount=2;
                                                            _listArr = (NSMutableArray *)pubPlaylistObj.allData;
//                                                            [self.tableView removeFooter];
//                                                            [self.tableView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                        }else{
                                                            if (_listArr) {
                                                              [_listArr removeAllObjects];
                                                            }
                                                        }
                                                        [self.tableView reloadData];
                                                    }else{
                                                        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                    }
                                                }];
    [self.topImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(imageViewClick:)];
    [self.topImageView addGestureRecognizer:singleTap];
}

- (void)imageViewClick:(id)sender{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"double_click_man_de" label:@"view/edit" value:nil];
    PlaylistInfoTableViewController *playlistInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistInfo"];
    playlistInfo.playlistObj = self.playlistObj;
    playlistInfo.listId = self.listId;
    [self.navigationController pushViewController:playlistInfo animated:YES];
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
    return [_listArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistDetail *listDetail;
    Music *list;
    if ([_listArr count]>indexPath.row) {
        listDetail = [_listArr objectAtIndex:indexPath.row];
        list = listDetail.music;
    }
    PlaylistItunesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:playlistItunesCell
                                                                        forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PlaylistItunesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:playlistItunesCell];
    }
    if ([_listArr count]>indexPath.row) {
        cell.aDelegate = self;
        cell.aIndexPathRow = indexPath.row;
        cell.nameLabel.text = list.trackName;
        if (listDetail.userAccount.userAvatarImageLargeURL!=nil) {
            [cell.iconImageView sd_setImageWithURL:listDetail.userAccount.userAvatarImageLargeURL
                                  placeholderImage:[UIImage imageNamed:@"cellAvatarImage"]];
        }else{
            [cell.iconImageView setImage:[UIImage imageNamed:@"cellAvatarImage"]];
        }
        
        [cell.balancerView setSomething:list];
        //名字和add的样式
        cell.userNameLabel.text = listDetail.userAccount.nickname;
        cell.actionLabel.text = PTNSLocalizedString(@"AddButtonMsgKey", nil);

        NSString *iconStr = @"IconSoundCloud";
        if (listDetail.music.source==MusicSourceiTunes) {
            iconStr = @"cellMusicTunes";
        }
        [cell.fromIconImageView setImage:[UIImage imageNamed:iconStr]];

        NSString *singerStr = list.artistName;
        if ([PTUtilities isEmptyOrNull:singerStr]) {
            singerStr = PTNSLocalizedString(@"UnknowMsgKey", nil);
        }
        NSString *albumStr = list.albumName;
        if ([PTUtilities isEmptyOrNull:albumStr]) {
            albumStr = PTNSLocalizedString(@"UnknowMsgKey", nil);
        }
        cell.subNameLabel.text = [NSString stringWithFormat:@"%@·%@",singerStr,albumStr];
    }
    return cell;
}

- (NSMutableAttributedString *)setNameString:(NSString *)nameStr{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:nameStr];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor grayColor]
                       range:NSMakeRange([nameStr length]-3, 3)];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"HelveticaNeue" size:13]
                       range:NSMakeRange([nameStr length]-3, 3)];
    return attrString;
}

- (CGSize)getStringRect:(NSString*)aString
{
    CGSize size;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:18.0f]};
    size = [aString boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute
                                 context:nil].size;
    return  size;
}

- (NSArray *)rightButtonsWithAllowDelete:(BOOL)isAllowDe
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"IconAddWhite"]];
    
    SWUtilityButton *button = [rightUtilityButtons firstObject];
    button.normolBackgroudColor = [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0];
    button.highlitedBackgroudColor = [UIColor colorWithRed:0.07 green:0.6f blue:0.16f alpha:1.0];
    
    if (isAllowDe && ![self.whereF isEqualToString:@"searchPlaylist"]) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor]
                                                     icon:[UIImage imageNamed:@"iconDeleteWhite"]];
        SWUtilityButton *button = [rightUtilityButtons lastObject];
        button.normolBackgroudColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f];
        button.highlitedBackgroudColor = [UIColor colorWithRed:208/255.0f green:2/255.0f blue:27/255.0f alpha:1.0f];
    }
    return rightUtilityButtons;
}

#pragma mark - header and footer

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    [aView setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]];
    UILabel *songTotleCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, tableView.frame.size.width-30, 20)];
    [songTotleCountLabel setText:[NSString stringWithFormat:PTNSLocalizedString(@"PlaylistSectionCountMsgKey", nil),[self.playlistObj.totalNum intValue]-_deleteCount]];
    [aView addSubview:songTotleCountLabel];
    
    if(![self.whereF isEqualToString:@"searchPlaylist"]){
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [addButton setTitle:@"add" forState:UIControlStateNormal];
        [addButton setBackgroundImage:[UIImage imageNamed:@"addButton_bg"] forState:UIControlStateNormal];
//        [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addMusicButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setFrame:CGRectMake(tableView.frame.size.width-75, 7, 60, 25)];
        [aView addSubview:addButton];
    }
    return aView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self increasePlaylistCount];
    NSMutableArray *allMusics = [NSMutableArray array];
    for (PlaylistDetail *playlistDetail in _listArr) {
        [allMusics addObject:playlistDetail.music];
    }
    [[YLAudioPlayer sharedAudioPlayer] playTracks:allMusics startIndex:indexPath.row];
    [YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId = self.listId;
    postNotification(STOP_ITUNES_PLAY_ALL_START, nil, nil);
    [self reSetAllPlayButtonState];
    if ([self.whereF isEqualToString:@"topView"]) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_manul_1" action:@"Click_manual_1" label:@"manual_play" value:nil];
    }else if ([self.whereF isEqualToString:@"hot"]){
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_hot_playlist_1" action:@"Click_hot_1" label:@"hot_playlist_play" value:nil];
    }else if ([self.whereF isEqualToString:@"new"]){
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_new_playlist_1" action:@"Click_new_1" label:@"new_playlist_play" value:nil];
    }
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"play_one" value:nil];
    [self.tableView reloadData];
}

#pragma -mark PlaylistItunesTableViewCell delegate

- (void)selectUserNameActionWithIndexPathRow:(NSInteger)aIndexPathRow{
    PlaylistDetail *playlistDetail = [_listArr objectAtIndex:aIndexPathRow];
    ProfileViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profile.currentUser = playlistDetail.userAccount;
    [self.navigationController pushViewController:profile animated:YES];
}

- (void)playlistItunesTableViewCellActionButtonClicked:(PlaylistItunesTableViewCell *)cell {
    UserAccount *user = [self userAccount];
    PlaylistDetail *playlistDetail = [_listArr objectAtIndex:cell.aIndexPathRow];
    currentSelectCell = cell;
    BOOL isShowPurchase = ((playlistDetail.music.source == MusicSourceiTunes) && ![playlistDetail.music.purchaseUrl isEmpty]);
    BOOL isAddDelete = ([user.userId intValue] == [playlistDetail.userAccount.userId intValue]) ? YES : NO;
    UIActionSheet *actionSheet = nil;
    if (isAddDelete) {
        if (isShowPurchase) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil) destructiveButtonTitle:nil otherButtonTitles:PTNSLocalizedString(@"AddToPlayListKey", nil),PTNSLocalizedString(@"PurchaseKey", nil),PTNSLocalizedString(@"ShareKey", nil), PTNSLocalizedString(@"DeleteKey", nil),nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil) destructiveButtonTitle:nil otherButtonTitles:PTNSLocalizedString(@"AddToPlayListKey", nil),PTNSLocalizedString(@"ShareKey", nil), PTNSLocalizedString(@"DeleteKey", nil),nil];
        }
        
    } else {
        if (isShowPurchase) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil) destructiveButtonTitle:nil otherButtonTitles:PTNSLocalizedString(@"AddToPlayListKey", nil),PTNSLocalizedString(@"PurchaseKey", nil),PTNSLocalizedString(@"ShareKey", nil), nil];

        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil) destructiveButtonTitle:nil otherButtonTitles:PTNSLocalizedString(@"AddToPlayListKey", nil),PTNSLocalizedString(@"ShareKey", nil), nil];
        }
    }
    [actionSheet showInView:self.view];
}

#pragma -mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        // Delete button was pressed
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:_aCell];
        PlaylistDetail *playlistDetail = [_listArr objectAtIndex:cellIndexPath.row];
        Music *musicObj = playlistDetail.music;
        [_listArr removeObjectAtIndex:cellIndexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        UserAccount *user = [self userAccount];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:user.userId forKey:@"uid"];
        [dic setObject:user.userToken forKey:@"token"];
        [dic setObject:self.listId forKey:@"lid"];
        [dic setObject:musicObj.sid forKey:@"sid"];
        [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"PlaylistRemoveLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
        [[PTAppClientEngine sharedClient] deleteOneMusicWithMusicDic:dic
                                                          completion:^(NSError *error){
                                                              if (error!=nil) {
                                                                  [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                              }else{
                                                                  [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"PlaylistRemoveMusicOkMsgKey", nil)];
                                                              }
                                                              [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"slide_man_de" label:@"delete" value:nil];
                                                              _deleteCount++;
                                                              [self.tableView reloadData];
                                                          }];
    }
}

- (NSMutableDictionary *)returnMusicDicWith:(Music *)musicObj{
    UserAccount *user = [self userAccount];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@",musicObj.trackId] forKey:@"meid"];
    [dic setObject:[NSNumber numberWithInteger:musicObj.source] forKey:@"eid"];
    [dic setObject:[NSString stringWithFormat:@"%@",user.userId] forKey:@"uid"];
    [dic setObject:user.userToken forKey:@"token"];
    [dic setObject:musicObj.trackName forKey:@"name"];
    [dic setObject:@"M" forKey:@"source_type"];
    if (![PTUtilities isEmptyOrNull:[self retStringWithUrl:musicObj.trackURL]])             // trackurl
        [dic setObject:[self retStringWithUrl:musicObj.trackURL] forKey:@"url"];
    if (![PTUtilities isEmptyOrNull:musicObj.genreName])                                    // genreName
        [dic setObject:musicObj.genreName forKey:@"style"];
    if (![PTUtilities isEmptyOrNull:musicObj.albumName])                                    // albumName
        [dic setObject:musicObj.albumName forKey:@"album"];
    if ([musicObj.trackTime intValue]<=0)                                                   // trackTime
        [dic setObject:musicObj.trackTime forKey:@"time_length"];
    if(![PTUtilities isEmptyOrNull:[self retStringWithUrl:musicObj.artworkUrlBigger]])      // artworkUrlBigger
        [dic setObject:[self retStringWithUrl:musicObj.artworkUrlBigger] forKey:@"ico_big"];
    if(![PTUtilities isEmptyOrNull:[self retStringWithUrl:musicObj.artworkUrlMini]])        // artworkUrlMini
        [dic setObject:[self retStringWithUrl:musicObj.artworkUrlMini] forKey:@"ico_small"];
    if(![PTUtilities isEmptyOrNull:[self retStringWithUrl:musicObj.artworkUrlNormal]])      // artworkUrlNormal
        [dic setObject:[self retStringWithUrl:musicObj.artworkUrlNormal] forKey:@"ico_nomal"];
    if (![PTUtilities isEmptyOrNull:musicObj.pubYear])                                      // pubYear
        [dic setObject:musicObj.pubYear forKey:@"pub_year"];
    if (![PTUtilities isEmptyOrNull:musicObj.artistName])                                   // artistName
        [dic setObject:musicObj.artistName forKey:@"singer"];
    if(![PTUtilities isEmptyOrNull:musicObj.musicLang])                                     // musicLang
        [dic setObject:musicObj.musicLang forKey:@"music_lang"];
    return dic;
}

- (NSString *)retStringWithUrl:(NSURL *)url{
    return [url absoluteString];
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

#pragma mark button action
- (IBAction)likerButtonAction:(id)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"liker" value:nil];
    LikeAndFeederTableViewController *likerAndFeeder = [self.storyboard instantiateViewControllerWithIdentifier:@"likerAndFeeder"];
    likerAndFeeder.whereF=PTNSLocalizedString(@"PlaylistItunesLikerMsgKey", nil);
    likerAndFeeder.listIdStr=[NSString stringWithFormat:@"%@",self.playlistObj.listId];
    [self.navigationController pushViewController:likerAndFeeder animated:YES];
}

- (IBAction)feederButtonAction:(id)sender {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"feeder" value:nil];
    LikeAndFeederTableViewController *likerAndFeeder = [self.storyboard instantiateViewControllerWithIdentifier:@"likerAndFeeder"];
    likerAndFeeder.listIdStr=[NSString stringWithFormat:@"%@",self.playlistObj.listId];
    likerAndFeeder.whereF = PTNSLocalizedString(@"PlaylistItunesFeederMsgKey", nil);
    [self.navigationController pushViewController:likerAndFeeder animated:YES];
}

- (IBAction)goodButtonAction:(id)sender{
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"LikeLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
    UserAccount *user = [self userAccount];
    [[PTAppClientEngine sharedClient] playlistPraiseWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                        listId:self.listId
                                                         token:user.userToken
                                                        action:_isDing==0?@"add":@"del"
                                                    completion:^(PlaylistObj *playlist,NSError *error){
                                                        if (!error) {
                                                            if(_isDing==0){
                                                                _isDing=1;
                                                                [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"like" value:nil];
                                                            }else{
                                                                [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"unlike" value:nil];
                                                                _isDing=0;
                                                            }
                                                            self.playlistObj = playlist;
                                                            [self initUIValue];
                                                            self.likerLabel.text = [NSString stringWithFormat:@"%d",_isLikerCount];
                                                            NSString *isDingStr = _isDing==0?@"like_no":@"like";
                                                            [self.goodButton setImage:[UIImage imageNamed:isDingStr] forState:UIControlStateNormal];
                                                            [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"LikeOkMsgKey", nil)];
                                                        }else{
                                                            [SVProgressHUD showSuccessWithStatus:[error localizedDescription]];
                                                        }
                                                    }];
}

- (IBAction)shareButtonAction:(id)sender{
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"FeededLoadingMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
    UserAccount *user = [self userAccount];
    [[PTAppClientEngine sharedClient] playlistFlowWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                        listId:self.listId
                                                         token:user.userToken
                                                        action:_isFlow==0?@"add":@"del"
                                                        completion:^(PlaylistObj *playlist,NSError *error){
                                                            if (!error) {
                                                                if(_isFlow==0){
                                                                    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"feed" value:nil];
                                                                    _isFlow=1;
                                                                }else{
                                                                    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"unfeed" value:nil];
                                                                    _isFlow=0;
                                                                }
                                                                self.playlistObj = playlist;
                                                                [self initUIValue];
                                                                self.feederLabel.text = [NSString stringWithFormat:@"%d",_isFlowCount];
                                                                NSString *isFlowStr = _isFlow==0?@"FEED_no":@"FEED";
                                                                [self.shareButton setImage:[UIImage imageNamed:isFlowStr] forState:UIControlStateNormal];
                                                                [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"FeededOkMsgKey", nil)];
                                                                [PTUtilities setNeedRefrshPlaylist:YES];
                                                            }else{
                                                                [SVProgressHUD showSuccessWithStatus:[error localizedDescription]];
                                                            }
                                                    }];
}

- (void)reSetAllPlayButtonState{
    _isPlayingAll=NO;
    _isFristPlayAll=NO;
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *listIdStr = [userDefaults objectForKey:@"playlistDetailPageAllPlayListId"];
    if (listIdStr) {
        [userDefaults removeObjectForKey:listIdStr];
        [userDefaults removeObjectForKey:@"playlistDetailPageAllPlayListId"];
    }
    [userDefaults synchronize];
}

- (IBAction)playButtonAction:(id)sender{
    if ([_listArr count]<1) {
        [SVProgressHUD showErrorWithStatus:PTNSLocalizedString(@"noMusicToPlay", nil)];
        return;
    }
    postNotification(STOP_ITUNES_PLAY_ALL_START, nil, nil);
    if (!_isFristPlayAll) {
        NSMutableArray *allMusics = [NSMutableArray array];
        for (PlaylistDetail *playlistDetail in _listArr) {
            [allMusics addObject:playlistDetail.music];
        }
        [[YLAudioPlayer sharedAudioPlayer] playTracks:allMusics startIndex:0];
        [YLAudioPlayer sharedAudioPlayer].currentPlayingPlaylistId = self.listId;
        
        [self increasePlaylistCount];

        if ([self.whereF isEqualToString:@"topView"]) {
            [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_manul_1" action:@"Click_manual_1" label:@"manual_play" value:nil];
        }else if ([self.whereF isEqualToString:@"hot"]){
            [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_hot_playlist_1" action:@"Click_hot_1" label:@"hot_playlist_play" value:nil];
        }else if ([self.whereF isEqualToString:@"new"]){
            [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_new_playlist_1" action:@"Click_new_1" label:@"new_playlist_play" value:nil];
        }
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"Click_man_de" label:@"play_all" value:nil];
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *listIdStr = [userDefaults objectForKey:@"playlistDetailPageAllPlayListId"];
    if (listIdStr) {
        [userDefaults removeObjectForKey:listIdStr];
    }
    [userDefaults setObject:[NSString stringWithFormat:@"playlistDetailPlay%@",self.listId] forKey:@"playlistDetailPageAllPlayListId"];
    if (!_isPlayingAll) {
        _isPlayingAll=YES;
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
        
        if (_isFristPlayAll) {
            [[YLAudioPlayer sharedAudioPlayer] play];
        }
        _isFristPlayAll=YES;
        [userDefaults setObject:@"on" forKey:[NSString stringWithFormat:@"playlistDetailPlay%@",self.listId]];
    }else{
        _isPlayingAll=NO;
        [[YLAudioPlayer sharedAudioPlayer] pause];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
        [userDefaults setObject:@"off" forKey:[NSString stringWithFormat:@"playlistDetailPlay%@",self.listId]];
    }
    [userDefaults synchronize];
}

- (IBAction)cancelButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(playlistItunesDisMissView)]) {
        [self.delegate playlistItunesDisMissView];
    }
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addMusicButtonAction:(id)sender{
    if (_isFlow==0) {
        [PTUtilities showAlertMessageWithTitle:PTNSLocalizedString(@"PlaylistRemoveAlertMsgKey", nil)
                                       message:PTNSLocalizedString(@"UnsubscribeAddDataMsgKey", nil)
                                 okButtonTitle:PTNSLocalizedString(@"OKButtonMsgKey", nil)];
        return;
    }
    PlaylistSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistSearchVC"];
    searchVC.whereF=self.listId;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma -mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UALog(@"button index %ld",buttonIndex);
    UALog(@"button title %@",[actionSheet buttonTitleAtIndex:buttonIndex]);

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:PTNSLocalizedString(@"AddToPlayListKey", nil)]) {
        [self addMusicToPlaylist];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:PTNSLocalizedString(@"PurchaseKey", nil)]) {
        [self purchaseSong];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:PTNSLocalizedString(@"ShareKey", nil)]) {
        [self shareSong];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:PTNSLocalizedString(@"DeleteKey", nil)]) {
        [self deleteSongFromPlaylist];
    }
}

- (void)addMusicToPlaylist {
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"P_man_de" action:@"slide_man_de" label:@"add" value:nil];
    PlaylistDetail *playlistDetail = [_listArr objectAtIndex:currentSelectCell.aIndexPathRow];
    Music *musicObj = playlistDetail.music;
    AddMusicToPlaylistViewController *addMusicToPlaylist = [self.storyboard instantiateViewControllerWithIdentifier:@"addMusicToPlaylistVC"];
    addMusicToPlaylist.playlistObjDic=[self returnMusicDicWith:musicObj];
    [self.navigationController pushViewController:addMusicToPlaylist animated:YES];
}

- (void)deleteSongFromPlaylist {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PTNSLocalizedString(@"PlaylistRemoveAlertMsgKey" ,nil)
                                              message:PTNSLocalizedString(@"PlaylistRemoveBeSureMsgKey" ,nil)
                                             delegate:self
                                    cancelButtonTitle:PTNSLocalizedString(@"PlaylistRemoveCancelMsgKey" ,nil)
                                    otherButtonTitles:PTNSLocalizedString(@"PlaylistRemoveRemoveMsgKey" ,nil), nil];
    [alert show];
    _aCell = currentSelectCell;
}

- (void)purchaseSong {
    PlaylistDetail *playlistDetail = [_listArr objectAtIndex:currentSelectCell.aIndexPathRow];
    Music *musicObj = playlistDetail.music;
    NSURL *purchaseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&at=11l32tc&ct=duorey",musicObj.purchaseUrl]];
    [[UIApplication sharedApplication] openURL:purchaseUrl];
}

- (void)shareSong {
    PlaylistDetail *playlistDetail = [_listArr objectAtIndex:currentSelectCell.aIndexPathRow];
    Music *musicObj = playlistDetail.music;
    [PTUtilities shareSongOrListWithID:nil songID:[NSString stringWithFormat:@"%@",musicObj.sid] controller:self];
}

- (IBAction)sharePlaylistAction:(id)sender {
    [PTUtilities shareSongOrListWithID:self.listId songID:nil controller:self];
}

#pragma mark - private methods

/**
 *  歌单播放次数+1
 */
- (void)increasePlaylistCount {
    UserAccount *user = [PTUtilities readLoginUser];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:user.userId forKey:@"uid"];
    [dic setObject:user.userToken forKey:@"token"];
    [dic setObject:self.playlistObj.listId forKey:@"lid"];
    [dic setObject:self.playlistObj.listName forKey:@"list_name"];
    [[PTAppClientEngine sharedClient] recentPlaylistWithDic:dic
                                                 completion:^(NSError *error){
                                                     
                                                 }];
}

@end
