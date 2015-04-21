//
//  ItunesTableViewController.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ItunesTableViewController.h"
#import "ItunesTableViewCell.h"
#import "PTAppClientEngine.h"
#import "UserAccount.h"
#import "Music.h"
#import "UIImageView+WebCache.h"
#import "PlaylistInfoTableViewController.h"
#import "AddMusicToPlaylistViewController.h"
#import "SongObj.h"
#import "PubPlaylist.h"
#import "YLAudioPlayer.h"
#import "YLRefresh.h"
#import "UIViewController+Balancer.h"

#define ITUNES_CELL @"iTunesCell"

@interface ItunesTableViewController ()<ItunesTableViewCellDelegate,UIActionSheetDelegate>{
    NSArray *_listArr;
    NSArray *_itunesPlaylist;
    int _isDing;
    int _isFlow;
    BOOL _isPlayingAll;
    BOOL _isFristPlayAll;
    NSInteger currentSelectIndex;
}

@end

@implementation ItunesTableViewController

- (UserAccount *)userAccount{
    return [PTUtilities readLoginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self setUpBalancerView];
    [self.tableView addHeaderWithTarget:self action:@selector(dropViewDidBeginRefreshing:)];
    [self.tableView headerBeginRefreshing];
    
    addNotificationObserver(STOP_ITUNES_PLAY_ALL_START, self, @selector(reSetAllPlayButtonState), nil);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [userDefaults objectForKey:@"iTunesPlaylistAllPlay"];
    if (keyStr) {
        if ([keyStr isEqualToString:@"on"]) {
            _isPlayingAll = YES;
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
        }else{
            _isPlayingAll = NO;
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
        }
    }else{
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
    }
}

- (void)dropViewDidBeginRefreshing:(id)sender{
    __weak typeof(self) weakSelf = self;
    [SongObj getItunesMainValueWithCount:25 completion:^(NSArray *values, NSError *error){
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.tableView headerEndRefreshing];
        if (error==nil) {
            _itunesPlaylist=values;
            [self.tableView reloadData];
            id<ThirdpartyMusicProtocol> itunesObj = [_itunesPlaylist firstObject];
            if (![PTUtilities isEmptyOrNull:[[itunesObj iconBigURL] absoluteString]]) {
                [self.topImageView sd_setImageWithURL:[itunesObj iconBigURL]
                                     placeholderImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];
            }else{
                [self.topImageView setImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}


- (void)imageViewClick:(id)sender{
//    PlaylistInfoTableViewController *playlistInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistInfo"];
//    playlistInfo.listId = [NSString stringWithFormat:@"%d",self.listId];
//    [self.navigationController pushViewController:playlistInfo animated:YES];
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
    if ([self.whereF isEqualToString:@"Itunes"]) {
       return [_itunesPlaylist count];
    }
    return [_listArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItunesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ITUNES_CELL];
    if (cell==nil) {
        cell = [[ItunesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:ITUNES_CELL];
    }
    cell.delegate = self;
    cell.aIndexPathRow=(int)indexPath.row;
    id<ThirdpartyMusicProtocol> itunesObj = [_itunesPlaylist objectAtIndex:indexPath.row];
    cell.numberLabel.text = [NSString stringWithFormat:@"%d.",(int)(indexPath.row+1)];
    cell.nameLabel.text = itunesObj.songName;
    if(![PTUtilities isEmptyOrNull:[[itunesObj iconBigURL] absoluteString]]){
        [cell.iconImageView sd_setImageWithURL:[itunesObj iconBigURL]
                              placeholderImage:[UIImage imageNamed:@"DefaultCoverNo2"]];
    }else{
        [cell.iconImageView setImage:[UIImage imageNamed:@"DefaultCoverNo2"]];
    }
    cell.subNameLable.text = [NSString stringWithFormat:@"%@·%@",itunesObj.album,itunesObj.singer];
    [cell.balancerView setSomething:[itunesObj duoreyMusicModel]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    [aView setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]];
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, tableView.frame.size.width-30, 20)];
    if ([self.whereF isEqualToString:@"Itunes"]) {
        [aLabel setText:[NSString stringWithFormat:PTNSLocalizedString(@"iTunesCellCountMsgKey", nil),(int)[_itunesPlaylist count]]];
    }else
        [aLabel setText:[NSString stringWithFormat:PTNSLocalizedString(@"iTunesCellCountMsgKey", nil),(int)[_listArr count]]];
    [aView addSubview:aLabel];
    return aView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [[YLAudioPlayer sharedAudioPlayer] playCurrentTrack:[self returnMusicObjWithItunesObj:[_itunesPlaylist objectAtIndex:indexPath.row]]];
    [[YLAudioPlayer sharedAudioPlayer] playTracks:[self musicObjArray] startIndex:indexPath.row];
//    postNotification(MusicPlayCellPlayViewStartingNotification, nil, nil);
    postNotification(STOP_PLAYLIST_PLAY_ALL_START, nil, nil);
    [self reSetAllPlayButtonState];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma -mark ItunsTableViewCell Delegate

- (void)moreButtonActionWithIndex:(int)aIndexPathRow{
    currentSelectIndex = aIndexPathRow;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:PTNSLocalizedString(@"CancelButtonMsgKey", nil) destructiveButtonTitle:nil otherButtonTitles:PTNSLocalizedString(@"AddToPlayListKey", nil),PTNSLocalizedString(@"PurchaseKey", nil),nil];
    [actionSheet showInView:self.view];
}

-(NSMutableArray *)musicObjArray
{
    NSMutableArray *array = [NSMutableArray array];
    for (id<ThirdpartyMusicProtocol> obj in _itunesPlaylist)
    {
        [array addObject:[obj duoreyMusicModel]];
    }
    return array;
}

#pragma mark button action
- (IBAction)goodButtonAction:(id)sender {
    UserAccount *user = [self userAccount];
    [[PTAppClientEngine sharedClient] playlistPraiseWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                        listId:[NSString stringWithFormat:@"%d",self.listId]
                                                         token:user.userToken
                                                        action:_isDing==0?@"add":@"del"
                                                    completion:^(PlaylistObj *playlist,NSError *error){
                                                        if(_isDing==0) _isDing=1;
                                                        else _isDing=0;
                                                        NSString *isDingStr = _isDing==0?@"like_no":@"like";
                                                        [self.goodButton setImage:[UIImage imageNamed:isDingStr] forState:UIControlStateNormal];
                                                    }];
}

- (IBAction)shareButtonAction:(id)sender{
    UserAccount *user = [self userAccount];
    [[PTAppClientEngine sharedClient] playlistFlowWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                      listId:[NSString stringWithFormat:@"%d",self.listId]
                                                       token:user.userToken
                                                      action:_isFlow==0?@"add":@"del"
                                                  completion:^(PlaylistObj *playlist,NSError *error){
                                                      if(_isFlow==0) _isFlow=1;
                                                      else _isFlow=0;
                                                      NSString *isFlowStr = _isFlow==0?@"FEED_no":@"FEED";
                                                      [self.shareButton setImage:[UIImage imageNamed:isFlowStr] forState:UIControlStateNormal];
                                                  }];
}

#pragma mark all play button
- (void)reSetAllPlayButtonState{
    _isPlayingAll=NO;
    _isFristPlayAll=NO;
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"off" forKey:@"iTunesPlaylistAllPlay"];
    [userDefaults synchronize];
}

- (IBAction)playButtonAction:(id)sender {
    if ([_itunesPlaylist count]<1) {
        [SVProgressHUD showErrorWithStatus:@"no music to play"];
        return;
    }
    postNotification(STOP_PLAYLIST_PLAY_ALL_START, nil, nil);
    if (!_isFristPlayAll) {
        NSMutableArray *allMusics = [NSMutableArray array];
        for (id<ThirdpartyMusicProtocol> itunes in _itunesPlaylist) {
            [allMusics addObject:[itunes duoreyMusicModel]];
        }
        [[YLAudioPlayer sharedAudioPlayer] playTracks:allMusics startIndex:0];
//        postNotification(MusicPlayCellPlayViewStartingNotification, nil, nil);
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!_isPlayingAll) {
        _isPlayingAll=YES;
        if (_isFristPlayAll) {
            [[YLAudioPlayer sharedAudioPlayer] play];
        }
        _isFristPlayAll=YES;
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPause"] forState:UIControlStateNormal];
        [userDefaults setObject:@"on" forKey:@"iTunesPlaylistAllPlay"];
    }else{
        _isPlayingAll=NO;
        [[YLAudioPlayer sharedAudioPlayer] pause];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"musicPlay"] forState:UIControlStateNormal];
        [userDefaults setObject:@"off" forKey:@"iTunesPlaylistAllPlay"];
    }
    [userDefaults synchronize];
}

#pragma -mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:PTNSLocalizedString(@"AddToPlayListKey", nil)]) {
        [self addMusicToPlaylist];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:PTNSLocalizedString(@"PurchaseKey", nil)]) {
        [self purchaseSong];
    }
}

#pragma -mark purchase, add to playlist

- (void)purchaseSong {
    id<ThirdpartyMusicProtocol> musicObj;
    if ([self.whereF isEqualToString:@"Itunes"]){
        musicObj = [_itunesPlaylist objectAtIndex:currentSelectIndex];
    }
    else{
        musicObj = [_listArr objectAtIndex:currentSelectIndex];
    }
    if (musicObj.purchaseUrl) {
        NSURL *purchaseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&at=11l32tc&ct=duorey",musicObj.purchaseUrl]];
        [[UIApplication sharedApplication] openURL:purchaseUrl];
    }
}

- (void)addMusicToPlaylist {
    id<ThirdpartyMusicProtocol> musicObj;
    if ([self.whereF isEqualToString:@"Itunes"]){
        musicObj = [_itunesPlaylist objectAtIndex:currentSelectIndex];
    }
    else{
        musicObj = [_listArr objectAtIndex:currentSelectIndex];
    }
    AddMusicToPlaylistViewController *addMusicToPlaylist = [self.storyboard instantiateViewControllerWithIdentifier:@"addMusicToPlaylistVC"];
    addMusicToPlaylist.playlistObjDic=[musicObj duoreySystemMusicDictionary];
    [self.navigationController pushViewController:addMusicToPlaylist animated:YES];
}
@end

