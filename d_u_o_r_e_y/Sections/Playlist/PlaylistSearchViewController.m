//
//  PlaylistSearchTableViewController.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistSearchViewController.h"
#import "PlaylistSearchViewCell.h"
#import "PTDefinitions.h"
#import "SearchAppleMusic.h"
#import "SoundCloudMusic.h"
#import "RidoMusic.h"
#import "SpotifyMusic.h"
#import "PTUtilities.h"
#import "UserAccount.h"
#import "PTAppClientEngine.h"
#import "YLAudioPlayer.h"
#import "SongObj.h"
#import "HistoryTableViewCell.h"
#import "AddMusicToPlaylistViewController.h"
#import "PlaylistItunesTableViewController.h"

#define Search_history_defautls_key @"SearchHistoryKey"

static NSString *const playlistSearchCell = @"playlistSearchCell";

@interface PlaylistSearchViewController ()<UISearchBarDelegate,PlaylistSearchViewCellDelegate
,UITableViewDataSource,UITableViewDelegate,HistoryTableViewCellDelegate,PlaylistItunesTableViewControllerDelegate>{
    
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property ( nonatomic) NSMutableArray *audioArr;
@property (nonatomic) NSMutableDictionary *selectDic;
@property ( nonatomic) NSMutableArray *historyKeyArr;
@property ( nonatomic) BOOL isSearchIng;

@end

@implementation PlaylistSearchViewController
@synthesize delegate=delegate;

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.listTableView.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.backgroundColor = [UIColor clearColor];
        _searchBar.tintColor=[UIColor greenColor];
        _searchBar.placeholder = PTNSLocalizedString(@"PlaylistSearchPlaceholderMsgkey", nil);
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchBar_bg_grad"]
                                         forState:UIControlStateNormal];
    }
    
    return _searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    _historyKeyArr = [[NSMutableArray alloc] init];
    _audioArr = [[NSMutableArray alloc] init];
    _selectDic = [[NSMutableDictionary alloc] init];
    [_selectDic setObject:@"0" forKey:@"itunes"];
    [_selectDic setObject:@"0" forKey:@"rido"];
    [_selectDic setObject:@"0" forKey:@"sportify"];
    [_selectDic setObject:@"0" forKey:@"soundcloud"];
    
    self.hisTableView.delegate = self;
    self.hisTableView.dataSource = self;
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = _cancelButton;
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar sizeToFit];
    [self.searchBar becomeFirstResponder];
    
    _historyKeyArr = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:Search_history_defautls_key]) {
        [_historyKeyArr addObjectsFromArray:[userDefaults objectForKey:Search_history_defautls_key]];
    }
    
    if([_historyKeyArr count]>0){
        [self reloadHistoryTableView];
    }else{
        [self showInputWord];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - reload Table view

- (void)showInputWord{
    if ([_historyKeyArr count]<1) {
        [self.hisTableView setHidden:YES];
        [self.noDataView setHidden:NO];
        [self.listTableView setHidden:YES];
    }
}

- (void)showResultTableView{
    [self.hisTableView setHidden:YES];
    if ([_audioArr count]>0) {
        [self.noDataView setHidden:YES];
        [self.listTableView setHidden:NO];
    }else{
        [self.noDataView setHidden:NO];
        [self.listTableView setHidden:YES];
    }
}

- (void)reloadResultTableView{
    [self showResultTableView];
    [self.listTableView reloadData];
}

- (void)reloadHistoryTableView{
    [self.noDataView setHidden:YES];
    [self.hisTableView setHidden:NO];
    [self.listTableView setHidden:YES];
    [self.hisTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==self.hisTableView) {
        return 1;
    }
    // Return the number of sections.
    return [_audioArr count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView==self.hisTableView) {
        return [_historyKeyArr count];
    }else{
        if ([[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count]<4 ||
            [[_selectDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] intValue]==1) {
            return [[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count];
        }else{
            return 3;
        }
    }
}

- (void)audioConfigureCell:(PlaylistSearchViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSArray *allValueArr = [[[_audioArr objectAtIndex:indexPath.section] allValues] objectAtIndex:0];
    id<ThirdpartyMusicProtocol> thirdpartyMusic = [allValueArr objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [thirdpartyMusic songName];
    
    switch ([thirdpartyMusic source]) {
        case MusicSourceSoundCloud:
        {
            NSString *singerStr = [thirdpartyMusic singer];
            NSString *albumStr = [thirdpartyMusic album];
            if ([PTUtilities isEmptyOrNull:singerStr]) {
                singerStr = PTNSLocalizedString(@"UnknowMsgKey",nil);
            }
            if ([PTUtilities isEmptyOrNull:albumStr]) {
                albumStr = PTNSLocalizedString(@"SoundCloudMsgKey",nil);
            }
            cell.subNameLabel.text = [NSString stringWithFormat:@"%@·%@",albumStr,singerStr];
        }
            break;
        case MusicSourceSpotify:
        {
            cell.subNameLabel.text = [NSString stringWithFormat:@"%@·%@",[thirdpartyMusic singer],[thirdpartyMusic album]];
        }
            break;
        case MusicSourceRdio:
        {
            cell.subNameLabel.text = [NSString stringWithFormat:@"%@·%@",[thirdpartyMusic singer],[thirdpartyMusic album]];
        }
            break;
        default:
        {
            NSString *albumStr = [thirdpartyMusic album];
            if (!albumStr && [albumStr isEmpty]) {
                albumStr=PTNSLocalizedString(@"UnknowMsgKey",nil);
            }
            cell.subNameLabel.text = [NSString stringWithFormat:@"%@·%@",[thirdpartyMusic singer],albumStr];
        }
            break;
    }
    
    [cell.balancerView setSomething:[thirdpartyMusic duoreyMusicModel]];}

- (void)hisyoryConfigureCell:(HistoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if ([_historyKeyArr count]>indexPath.row) {
        NSString *keyStr = [_historyKeyArr objectAtIndex:indexPath.row];
        cell.keyLabel.text = keyStr;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.hisTableView) {
        static NSString *historyTableIdentifier = @"playlistHistoryCell";
        HistoryTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:historyTableIdentifier];
        cell.delegate=self;
        cell.aIndexPathRow = indexPath.row;
        if (cell == nil) {
            cell = [[HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:historyTableIdentifier];
        }
        [self hisyoryConfigureCell:cell atIndexPath:indexPath];
        return cell;
    }else{
        PlaylistSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:playlistSearchCell];
        
        if (cell==nil) {
            cell = [[PlaylistSearchViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:playlistSearchCell];
        }
        cell.aIndexPath=indexPath;
        cell.delegate=self;
        [self audioConfigureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.hisTableView) {
        [self.hisTableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.searchBar setText:[_historyKeyArr objectAtIndex:indexPath.row]];
        [self performSelector:@selector(autoSearch) withObject:nil afterDelay:0.3];
    }else{
        NSArray *allValueArr = [[[_audioArr objectAtIndex:indexPath.section] allValues] objectAtIndex:0];
        id<ThirdpartyMusicProtocol> thirdpartyMusic = [allValueArr objectAtIndex:indexPath.row];
        Music *music = [thirdpartyMusic duoreyMusicModel];
        
        switch ([thirdpartyMusic source]) {
            case MusicSourceSoundCloud:
            {
                [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_Search" action:@"Click_search_result" label:@"S_Search_result_2_play" value:nil];
            }
                break;
            case MusicSourceSpotify:
                break;
            case MusicSourceRdio:
                break;
            default:
            {
                [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_Search" action:@"Click_search_result" label:@"S_Search_result_1_play" value:nil];
            }
                break;
        }
        
        [self.listTableView reloadData];
        [[YLAudioPlayer sharedAudioPlayer] playCurrentTrack:music];
//        postNotification(MusicPlayCellPlayViewStartingNotification, nil, nil);
        postNotification(STOP_ITUNES_PLAY_ALL_START, nil, nil);
        postNotification(STOP_PLAYLIST_PLAY_ALL_START, nil, nil);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView==self.hisTableView){
        return 44.0f;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView==self.listTableView &&
        [[_selectDic objectForKey:[NSString stringWithFormat:@"%d",(int)section]] intValue]==0
        && [[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count]>3) {
        return 30;
    }
    return 0.1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==self.hisTableView) {
        return 0.1;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView!=self.listTableView) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }else{
        NSString *s = [NSString stringWithFormat:@"%@ result",[[[_audioArr objectAtIndex:section] allKeys] objectAtIndex:0]];
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        [aView setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [aView addSubview:imageView];
        if ([s isEqualToString:@"iTunes result"]) {
            [imageView setImage:[UIImage imageNamed:@"cellMusicTunes"]];
        }else if([s isEqualToString:@"Spotify result"]){
            [imageView setImage:[UIImage imageNamed:@"IconSportify"]];
        }else if([s isEqualToString:@"SoundCloud result"]){
            [imageView setImage:[UIImage imageNamed:@"IconSoundCloud"]];
        }else if([s isEqualToString:@"Rido result"]){
            [imageView setImage:[UIImage imageNamed:@"IconRdio"]];
        }
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [aLabel setNumberOfLines:0];
        CGSize size = [self getStringRect:s];
        [aLabel setText:s];
        [aLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        [aLabel setTextColor:[UIColor grayColor]];
        [aLabel setFrame:CGRectMake(tableView.frame.size.width/2-size.width/2+20,0, size.width, 30)];
        [aView addSubview:aLabel];
        [imageView setFrame:CGRectMake(aLabel.frame.origin.x-30, 5, 20, 20)];
        return aView;
    }
}

- (CGSize)getStringRect:(NSString*)aString
{
    CGSize size;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.0f]};
    size = [aString boundingRectWithSize:CGSizeMake(self.listTableView.frame.size.width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute
                                 context:nil].size;
    return  size;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ((tableView==self.listTableView && [[_selectDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] intValue]==0
         && [[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count]>3)) {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        [aView setBackgroundColor:[UIColor whiteColor]];
        UIButton *seeMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [seeMoreButton setFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        [seeMoreButton setImage:[UIImage imageNamed:@"see_more"] forState:UIControlStateNormal];
        seeMoreButton.tag=section;
        [seeMoreButton addTarget:self action:@selector(aLoadMoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:seeMoreButton];
        return aView;
    }else{
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (void)aLoadMoreButtonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    [_selectDic setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)button.tag]];
    [self.listTableView reloadData];
}


//#pragma mark - cancel button
//- (IBAction)CancelButtonAction:(id)sender {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

#pragma mark - back button action

- (IBAction)CancelButtonAction:(id)sender {
    if ([self.whereF length]>0) {
        [_searchBar resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
        if ([self.delegate respondsToSelector:@selector(creatPlaylistBack)]) {
            [self.delegate creatPlaylistBack];
        }
    }else{
        [self.searchBar resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)refreshSelectDic{
    [_selectDic setObject:@"0" forKey:@"itunes"];
    [_selectDic setObject:@"0" forKey:@"rido"];
    [_selectDic setObject:@"0" forKey:@"sportify"];
    [_selectDic setObject:@"0" forKey:@"soundcloud"];
}

#pragma mark - searchBarSearchButtonClicked

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

#pragma mark - search

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)autoSearch{
    [self searchBarSearchButtonClicked:self.searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _isSearchIng = YES;
    [self refreshSelectDic];
    [_audioArr removeAllObjects];
    [self.listTableView reloadData];

    NSString *keyStr = [_searchBar text];
    [_searchBar resignFirstResponder];
    if (![PTUtilities isEmptyOrNull:keyStr]) {
        if([_historyKeyArr containsObject:keyStr]){
            [_historyKeyArr removeObject:keyStr];
        }
        
        [_historyKeyArr insertObject:keyStr atIndex:0];
        
        if([_historyKeyArr count]>10){
            [_historyKeyArr removeObjectAtIndex:[_historyKeyArr count]-1];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_historyKeyArr forKey:Search_history_defautls_key];
        [userDefaults synchronize];
        
        [SVProgressHUD showWithStatus:PTNSLocalizedString(@"SearchLoadingMsgKey", nil)
                             maskType:SVProgressHUDMaskTypeBlack];
        
        SongObj *song = [[SongObj alloc] init];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
        
        __weak typeof(self) weakSelf = self;
        dispatch_group_async(group,queue, ^{
            [song doItunesSearchWithKey:keyStr
                             completion:^(NSArray *values, NSError *error){
                                 __strong typeof(self) strongSelf = weakSelf;
                                 if (strongSelf.isSearchIng) {
                                     strongSelf.isSearchIng = NO;
                                     [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"SearchOkMsgKey", nil)];
                                 }
                                 if (!error) {
                                     if (!values) return;
                                     if ([values count]>0) {
                                         NSDictionary *dic = @{@"iTunes":values};
                                         [_audioArr addObject:dic];
                                         if ([values count]>0) {
                                             [self.listTableView reloadData];
                                         }
                                     }
                                     [self showResultTableView];
                                 }
                             }];
        });
        
        dispatch_group_async(group,queue, ^{
//            UserAccount *user = [PTUtilities readLoginUser];
//            if (user.soundCloudAccount.accessToken!=nil) {
                [song doSoundCloudSearchWithKey:keyStr
                                     completion:^(NSArray *values, NSError *error){
                                         __strong typeof(self) strongSelf = weakSelf;
                                         if (strongSelf.isSearchIng) {
                                             strongSelf.isSearchIng = NO;
                                             [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"SearchOkMsgKey", nil)];
                                         }
                                         if (!error) {
                                             if (!values) return;
                                             if ([values count]>0) {
                                                 NSDictionary *dic = @{@"SoundCloud":values};
                                                 [_audioArr addObject:dic];
                                                 if ([values count]>0) {
                                                     [self.listTableView reloadData];
                                                 }
                                             }
                                             [self showResultTableView];
                                         }
                                     }];
//            }
        });
    }else{
        [self reloadHistoryTableView];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([_historyKeyArr count]<1) {
        [self showInputWord];
    }else{
        [self reloadHistoryTableView];
    }
}

#pragma mark -

-(void)addButtonAction:(NSIndexPath *)aIndexPath{
    NSArray *allValueArr = [[[_audioArr objectAtIndex:aIndexPath.section] allValues] objectAtIndex:0];
    id<ThirdpartyMusicProtocol> thirdpartyMusic = [allValueArr objectAtIndex:aIndexPath.row];
    NSDictionary *musicDic = [thirdpartyMusic duoreySystemMusicDictionary];
    
    if (self.delegate) {
        if ([self.whereF length]>0) {
            [SVProgressHUD showWithStatus:PTNSLocalizedString(@"AddToPlaylistTitleMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
            UserAccount *user = [PTUtilities readLoginUser];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            NSString *str = [PTUtilities dictionaryToJson:musicDic];
            [dic setObject:str forKey:@"data"];
            [dic setObject:self.whereF forKey:@"lid"];;
            [dic setObject:[NSString stringWithFormat:@"%@",user.userId] forKey:@"uid"];
            [dic setObject:user.userToken forKey:@"token"];
            [[PTAppClientEngine sharedClient] addOneMusicToHaveListWithMusicDic:dic
                                                                     completion:^(NSError *error){
                                                                         if (!error) {
                                                                             [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"MusicAddToPlaylistOKMsgKey", nil)];
                                                                             PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
                                                                             playlistItunesVC.listId = self.whereF;
                                                                             playlistItunesVC.delegate=self;
                                                                             [self.navigationController pushViewController:playlistItunesVC animated:YES];;
                                                                         }else{
                                                                             [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                         }
                                                                     }];
        }else{
            AddMusicToPlaylistViewController *addMusicPlaylistTabelVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addMusicToPlaylistVC"];
            addMusicPlaylistTabelVC.playlistObjDic=musicDic;
            [self.navigationController pushViewController:addMusicPlaylistTabelVC animated:YES];
        }
    }else{
        [SVProgressHUD showWithStatus:PTNSLocalizedString(@"AddToPlaylistTitleMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
        UserAccount *user = [PTUtilities readLoginUser];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *str = [PTUtilities dictionaryToJson:musicDic];
        [dic setObject:str forKey:@"data"];
        [dic setObject:self.whereF forKey:@"lid"];;
        [dic setObject:[NSString stringWithFormat:@"%@",user.userId] forKey:@"uid"];
        [dic setObject:user.userToken forKey:@"token"];
        [[PTAppClientEngine sharedClient] addOneMusicToHaveListWithMusicDic:dic
                                                                 completion:^(NSError *error){
                                                                     if (!error) {
                                                                         [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"MusicAddToPlaylistOKMsgKey", nil)];
                                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                                     }else{
                                                                         [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                     }
                                                                 }];
    }
}

- (void)playlistItunesDisMissView{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - delete search history
- (void)deleteSearchKey:(NSInteger)aIndexPathRow{
    [_historyKeyArr removeObjectAtIndex:aIndexPathRow];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_historyKeyArr forKey:Search_history_defautls_key];
    if ([_historyKeyArr count]<1) {
        [self showInputWord];
    }else{
        [self reloadHistoryTableView];
    }
}
@end
