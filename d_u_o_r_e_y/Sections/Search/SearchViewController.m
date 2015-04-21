//
//  SearchViewController.m
//  Duorey
//
//  Created by lixu on 14/11/10.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UALogger/UALogger.h>
#import <Rdio/Rdio.h>
#import <SVProgressHUD.h>
#import "SearchViewController.h"
#import "PTDefinitions.h"
#import "PTTheme.h"
#import "NSString+Additions.h"
#import "HistoryTableViewCell.h"
#import "PlayListTableViewCell.h"
#import "AudioTableViewCell.h"
#import "SongObj.h"
#import "PTUtilities.h"
#import "SoundCloudMusic.h"
#import "SpotifyMusic.h"
#import "RidoMusic.h"
#import "PTConstant.h"
#import "UserAccount.h"
#import "AddMusicToPlaylistViewController.h"
#import "PlaylistItunesTableViewController.h"
#import "Music.h"
#import "PTAppClientEngine.h"
#import "PlaylistObj.h"
#import "UIImageView+WebCache.h"
#import "YLAudioPlayer.h"
#import "SearchAppleMusic.h"

#define Search_history_defautls_key @"SearchHistoryKey"

@interface SearchViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,
HistoryTableViewCellDelegate,AudioTableViewCellDelegate,PlaylistItunesTableViewControllerDelegate>{
    NSString *_oldSearchString;
    
    CGRect aFrame;
    CGRect bFrame;
    float scrollViewBeginDraggingX;
    AddMusicToPlaylistViewController *_addMusicPlaylistTabelVC;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *segmentTopView;
@property (weak, nonatomic) IBOutlet UIView *showValueView;
@property (weak, nonatomic) IBOutlet UIImageView *searchNodeImage;
@property (weak, nonatomic) IBOutlet UILabel *searchNodeLabel;
@property (weak, nonatomic) IBOutlet UIView *searchNodeView;
@property (weak, nonatomic) IBOutlet UITableView *playListTableView;
@property (weak, nonatomic) IBOutlet UITableView *audioTableView;
@property (weak, nonatomic) IBOutlet UIView *playlistView;
@property (weak, nonatomic) IBOutlet UIView *audioView;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *playlistNoValueView;
@property (weak, nonatomic) IBOutlet UIView *audioNoViewView;

@property ( nonatomic) NSMutableArray *historyKeyArr;
@property ( nonatomic) NSMutableArray *playlistArr;
@property ( nonatomic) NSMutableArray *audioArr;

@property (nonatomic ) NSUInteger oldSegmentCount;
@property (nonatomic, strong) NSString *searchByStr;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic) NSMutableDictionary *selectDic;
@property (nonatomic) BOOL playlistClickMore;
@property (nonatomic) BOOL segmentedClick;
@property (nonatomic) BOOL isSearchIng;

@property (weak, nonatomic) IBOutlet UILabel *searchResultNullLabel;
@end

@implementation SearchViewController
#pragma mark -

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, _audioTableView.frame.size.width, 44)];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchBar_bg_grad"]
                                         forState:UIControlStateNormal];
        _searchBar.delegate = self;
        _searchBar.backgroundColor = [UIColor clearColor];
//        _searchBar.tintColor=[UIColor greenColor];
        _searchBar.placeholder = PTNSLocalizedString(@"SearchPlaceholderMsgKey", nil);
    }
    
    return _searchBar;
}

#pragma mark - lazy

- (void)setupUI{
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.titleView = self.searchBar;
    self.searchResultNullLabel.numberOfLines = 2;
    self.searchResultNullLabel.text = PTNSLocalizedString(@"SearchResultIsNullKey", nil);
    [self.searchBar sizeToFit];
    [self.searchBar becomeFirstResponder];

    _historyKeyArr = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:Search_history_defautls_key]) {
        [_historyKeyArr addObjectsFromArray:[userDefaults objectForKey:Search_history_defautls_key]];
    }
    
    _playlistArr = [[NSMutableArray alloc] init];
    _audioArr = [[NSMutableArray alloc] init];
    
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    self.playListTableView.delegate = self;
    self.playListTableView.dataSource = self;
    self.audioTableView.delegate = self;
    self.audioTableView.dataSource = self;
    aFrame = self.playListTableView.frame;
    bFrame = self.audioTableView.frame;
    
    _selectDic = [[NSMutableDictionary alloc] init];
    _playlistClickMore = NO;
    
    [PTThemeManager customizeWhiteHeadView:self.segmentTopView];
    _oldSegmentCount = 0;
    
    id<PTTheme> theme = [PTThemeManager sharedTheme];
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[PTNSLocalizedString(@"SegmentedControlPlayListMsgKey", nil), PTNSLocalizedString(@"SegmentedControlAudioMsgKey", nil)]];
//    self.segmentedControl.selectedTextColor = [theme greenColor];
    self.segmentedControl.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:17.0f],NSForegroundColorAttributeName:[theme blackColor]};
//    self.segmentedControl.textColor = [theme blackColor];
//    self.segmentedControl.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
//    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 49.5);
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionIndicatorHeight = 4.0f;
    self.segmentedControl.selectionIndicatorColor = [theme greenColor];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.segmentTopView addSubview:self.segmentedControl];
    
//    __weak typeof(self) weakSelf = self;
//    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
//        weakSelf.segmentedClick = YES;
//        [weakSelf.scrollView scrollRectToVisible:CGRectMake(weakSelf.scrollView.frame.size.width * index, 0, weakSelf.scrollView.frame.size.width, weakSelf.audioView.frame.size.height) animated:YES];
//    }];
//    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width*2, _scrollView.frame.size.height)];
//    [_scrollView scrollRectToVisible:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:YES];
//    
//    _playlistView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
//    _audioView.frame = CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width,_scrollView.frame.size.height);
//    
//    //add content
//    [_scrollView addSubview:self.playlistView];
//    [_scrollView addSubview:self.audioView];
    
    if([_historyKeyArr count]>0){
        [self reloadHistoryTableView];
    }else{
        [self showInputWord];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setBackButtonItemTitleByEmpty];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_Search" action:@"in" label:@"S_Search_in" value:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_Search" action:@"out" label:@"S_Search_out" value:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
//    scrollViewBeginDraggingX = scrollView.contentOffset.x;
//    UALog(@"scrollViewBeginDraggingX....%f",scrollViewBeginDraggingX);
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (!self.segmentedClick) {
//        CGFloat percent = scrollView.contentOffset.x / scrollView.contentSize.width;
//        if (scrollView.contentOffset.x > scrollViewBeginDraggingX) {
//            [self.segmentedControl animatedMoveLeftDirection:1 movePercent:percent];
//        }else if (scrollView.contentOffset.x < scrollViewBeginDraggingX){
//            [self.segmentedControl animatedMoveLeftDirection:0 movePercent:percent];
//        }
//    }
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
//    if (self.segmentedClick) {
//        self.segmentedClick = NO;
//        scrollViewBeginDraggingX = scrollView.contentOffset.x;
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    CGFloat pageWidth = scrollView.frame.size.width;
//    NSInteger page = scrollView.contentOffset.x / pageWidth;
//    [self.segmentedControl setSelectedSegmentIndex:page animated:NO];
//}

#pragma mark - back button action

- (IBAction)cancelButtonAction:(id)sender {
    if ([self.whereF length]>0) {
        [_searchBar resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
        if ([self.delegate respondsToSelector:@selector(creatPlaylistBack)]) {
            [self.delegate creatPlaylistBack];
        }
    }else{
        [self.searchBar resignFirstResponder];
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)refreshSelectDic{
    [_selectDic removeAllObjects];
//    [_selectDic setObject:@"0" forKey:@"itunes"];
//    [_selectDic setObject:@"0" forKey:@"rido"];
//    [_selectDic setObject:@"0" forKey:@"sportify"];
//    [_selectDic setObject:@"0" forKey:@"soundcloud"];
}

#pragma mark - reload Table view

- (void)showInputWord{
    if ([_historyKeyArr count]<1) {
        [self.historyTableView setHidden:YES];
        [self.segmentView setHidden:NO];
        [self.segmentTopView setHidden:YES];
        [self.showValueView setHidden:NO];
        [self.searchNodeView setHidden:NO];
        [self.playlistView setHidden:YES];
        [self.audioView setHidden:YES];
    }
    [self.searchNodeImage setImage:[UIImage imageNamed:@"search_iamge"]];
    [self.searchNodeLabel setText:PTNSLocalizedString(@"searchNodeLabelMsgKey", nil)];
}

- (void)showResultTableView{
    [self.historyTableView setHidden:YES];
    [self.segmentTopView setHidden:NO];
    [_searchNodeView setHidden:YES];
    
    if (_oldSegmentCount==0) {
        [self.audioView setHidden:YES];
        [self.playlistView setHidden:NO];
        if([_playlistArr count]>0){
            [self.playListTableView setHidden:NO];
            [self.playlistNoValueView setHidden:YES];
        }else{
            [self.playListTableView setHidden:YES];
            [self.playlistNoValueView setHidden:NO];
        }
    }else{
        [self.audioView setHidden:NO];
        [self.playlistView setHidden:YES];
        if ([_audioArr count]>0){
            [self.audioNoViewView setHidden:YES];
            [self.audioTableView setHidden:NO];
        }else{
            [self.audioNoViewView setHidden:NO];
            [self.audioTableView setHidden:YES];
        }
    }
    
    [self.segmentView setHidden:NO];
}

- (void)reloadResultTableView{
    [self showResultTableView];
    [self.playListTableView reloadData];
    [self.audioTableView reloadData];
}

- (void)reloadHistoryTableView{
    [self.historyTableView setHidden:NO];
    [self.playlistView setHidden:YES];
    [self.audioView setHidden:YES];
    [self.segmentView setHidden:YES];
    [self.segmentTopView setHidden:YES];
    [self.historyTableView reloadData];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView==self.audioTableView) {
        return [_audioArr count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_historyTableView isHidden]) {
        if (tableView==self.audioTableView) {
            if ([[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count]<4 ||
                [[_selectDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] intValue]==1) {
                return [[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count];
            }else{
                return 3;
            }
        }else{
            if ([_playlistArr count]<4 || _playlistClickMore) {
                return [_playlistArr count];
            }else{
                return 3;
            }
        }
    }else{
        if (tableView==self.historyTableView){
            return [_historyKeyArr count];
        }else{
            return 0;
        }
    }
}

- (void)hisyoryConfigureCell:(HistoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if ([_historyKeyArr count]>indexPath.row) {
        NSString *keyStr = [_historyKeyArr objectAtIndex:indexPath.row];
        cell.keyLabel.text = keyStr;
    }
}

- (void)playlistConfigureCell:(PlayListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    PlaylistObj *playlist = [_playlistArr objectAtIndex:indexPath.row];
    cell.nameLabel.text = playlist.listName;
    cell.songCountLabel.text = [NSString stringWithFormat:@"%@ songs",playlist.totalNum];
    [cell.mainImageView sd_setImageWithURL:[NSURL URLWithString:playlist.listIcon]
                          placeholderImage:[UIImage imageNamed:@"CD-Cover"]];
    cell.countLabel.text = [NSString stringWithFormat:@"%@",playlist.listenNum];
}

- (void)audioConfigureCell:(AudioTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
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

    [cell.balancerView setSomething:[thirdpartyMusic duoreyMusicModel]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.historyTableView) {
        static NSString *historyTableIdentifier = @"historyCell";
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
        if (tableView==self.audioTableView) {
            static NSString *audioTableIdentifier = @"audioCell";
            AudioTableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:audioTableIdentifier];
            cell.aIndexPath=indexPath;
            cell.delegate=self;
            if (cell == nil) {
                cell = [[AudioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:audioTableIdentifier];
            }
            [self audioConfigureCell:cell atIndexPath:indexPath];
            return cell;
        }else{
            static NSString *playlistTableIdentifier = @"playlistCell";
            PlayListTableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:playlistTableIdentifier];
            if (cell == nil) {
                cell = [[PlayListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:playlistTableIdentifier];
            }
            [self playlistConfigureCell:cell atIndexPath:indexPath];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView!=self.historyTableView) {
        if (tableView==self.audioTableView) {
            return 50;
        }
        return 100.0f;
    }
    return 44.0f;
}

- (void)loadMoreButtonPressed:(id)sender{
    if (_oldSegmentCount==0) {
        _playlistClickMore = YES;
        [self.playListTableView reloadData];
    }else{
        UIButton *button = (UIButton *)sender;
        [_selectDic setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)button.tag]];
        [self.audioTableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ((tableView==self.audioTableView && [[_selectDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] intValue]==0
         && [[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count]>3)
        ||(tableView==self.playListTableView && !_playlistClickMore && [_playlistArr count]>3)) {
        return 30;
    }
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==self.audioTableView) {
        return 30;
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(tableView==self.audioTableView){
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
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGSize)getStringRect:(NSString*)aString
{
    CGSize size;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.0f]};
    size = [aString boundingRectWithSize:CGSizeMake(self.audioTableView.frame.size.width, 0)
                                                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute
                                                            context:nil].size;
    return  size;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (tableView!=self.historyTableView) {
        if ((tableView==self.playListTableView && !_playlistClickMore && [_playlistArr count]>3) ||
            (tableView==self.audioTableView && [[_selectDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] intValue]==0 &&
             [[[[_audioArr objectAtIndex:section] allValues] objectAtIndex:0] count]>3)) {
            UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
            [aView setBackgroundColor:[UIColor whiteColor]];
            UIButton *seeMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [seeMoreButton setFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
            [seeMoreButton setImage:[UIImage imageNamed:@"see_more"] forState:UIControlStateNormal];
            seeMoreButton.tag=section;
            [seeMoreButton addTarget:self action:@selector(loadMoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [aView addSubview:seeMoreButton];
            return aView;
        }
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}
//#pragma mark - UIScrollViewDelegate
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    [self.searchBar resignFirstResponder];
//}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.historyTableView) {
        UALog(@"search music log...");
        [self.historyTableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.searchBar setText:[_historyKeyArr objectAtIndex:indexPath.row]];
        [self performSelector:@selector(autoSearch) withObject:nil afterDelay:0.3];
//        [self reloadResultTableView];
    }else{
        if (tableView==self.playListTableView) {
            [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_Search" action:@"Click_search_result" label:@"S_Search_result_5" value:nil];
            PlaylistObj *playlist = [_playlistArr objectAtIndex:indexPath.row];
            PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
            playlistItunesVC.listId = [NSString stringWithFormat:@"%@",playlist.listId];
            playlistItunesVC.whereF = @"searchPlaylist";
//            UINavigationController *aNavRegist = [[UINavigationController alloc] initWithRootViewController:playlistItunesVC];
//            [self presentViewController:aNavRegist animated:YES completion:nil];
            [self.navigationController pushViewController:playlistItunesVC animated:YES];
        }else{
            UALog(@"search history ");
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

            [self.audioTableView reloadData];
            [[YLAudioPlayer sharedAudioPlayer] playCurrentTrack:music];
//            postNotification(MusicPlayCellPlayViewStartingNotification, nil, nil);
            postNotification(STOP_ITUNES_PLAY_ALL_START, nil, nil);
            postNotification(STOP_PLAYLIST_PLAY_ALL_START, nil, nil);
        }
    }
}

#pragma mark - searchBarSearchButtonClicked

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
//    [self.historyTableView setHidden:NO];
//    [self.segmentView setHidden:YES];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_Search" action:@"Click_search" label:@"S_Search_enter" value:nil];
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
    [_playlistArr removeAllObjects];
    [_audioArr removeAllObjects];
    
    //
    [self.audioTableView reloadData];
    [self.playListTableView reloadData];
    
    [self showResultTableView];
    
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
                                     if([values count]>0){
                                         NSDictionary *dic = @{@"iTunes":values};
                                         [_audioArr addObject:dic];
                                         if ([values count]>0) {
                                             [self.audioTableView reloadData];
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
                                                     [self.audioTableView reloadData];
                                                 }
                                             }
                                             [self showResultTableView];
                                         }
                                     }];
//            }
        });
        
//        dispatch_group_async(group,queue, ^{
//            SpotifyObj *spotifyObj = [PTUtilities unarchiveObjectWithName:@"SpotifyObj"];
//            if (spotifyObj.access_token) {
//                [song doSpotifySearchWithKey:keyStr
//                                  completion:^(NSArray *values, NSError *error){
//                                      if (!error) {
//                                          if (!values) return;
//                                          NSDictionary *dic = @{@"Spotify":values};
//                                          [_audioArr addObject:dic];
//                                          if ([values count]>0) {
//                                              [self.audioTableView reloadData];
//                                          }
//                                          [self showResultTableView];
//                                      }
//                                  }];
//            }
//        });
//        
//        [[AppDelegate rdioInstance] authorizeFromController:self];
//        [AppDelegate rdioInstance].delegate = self;
//       dispatch_group_async(group,queue, ^{
//            RidoObj *ridoObj = [PTUtilities unarchiveObjectWithName:@"RidoObj"];
//            if (ridoObj.fullToken) {
//                [self doRidoSearchWithKey:keyStr];
//            }
//        });
//        dispatch_group_notify(group, queue,^{
//            UALog(@"is search over");
//        });
        UserAccount *user = [PTUtilities readLoginUser];
        [[PTAppClientEngine sharedClient] searchListWitUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                    withToken:user.userToken
                                                 withKeywords:keyStr
                                                   completion:^(NSArray *values,NSError *error){
                                                       __strong typeof(self) strongSelf = weakSelf;
                                                       if (strongSelf.isSearchIng) {
                                                           strongSelf.isSearchIng = NO;
                                                           [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"SearchOkMsgKey", nil)];
                                                       }
                                                       if (!error) {
                                                           [_playlistArr addObjectsFromArray:values];
                                                           [self.playListTableView reloadData];
                                                       }
                                                       [self showResultTableView];
                                                   }];
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

- (void)deleteSearchKey:(NSInteger)aIndexPathRow{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"S_Search" action:@"Click_search_result" label:@"S_Search_result_delete" value:nil];
    [_historyKeyArr removeObjectAtIndex:aIndexPathRow];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_historyKeyArr forKey:Search_history_defautls_key];
//    [self.historyTableView reloadData];
    if ([_historyKeyArr count]<1) {
        [self showInputWord];
    }else{
        [self reloadHistoryTableView];
    }
}

#pragma mark - rido api delegate
//- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken{
//    UALog(@"accessToken:%@",accessToken);
//    NSMutableArray *accArr = [[NSMutableArray alloc] init];
//    accArr = (NSMutableArray *)[accessToken componentsSeparatedByString:@"&"];
//    RidoObj *ridoObj = [[RidoObj alloc] init];
//    ridoObj.oauth_token = [[[accArr objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
//    ridoObj.oauth_token_secret = [[[accArr objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1];
//    ridoObj.fullToken = accessToken;
//    [PTUtilities archiveObject:ridoObj withName:@"RidoObj"];
//    [self doRidoSearchWithKey:@"aaa"];
//}
//
//- (void)rdioAuthorizationFailed:(NSError *)error{
//    UALog(@"error:%@",error);
//}
//
//- (void)doRidoSearchWithKey:(NSString *)searchKey{
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:searchKey forKey:@"query"];
//    [dic setObject:@"Track" forKey:@"types"];
//    [dic setObject:@"20" forKey:@"count"];
//    [[AppDelegate rdioInstance] callAPIMethod:@"search" withParameters:dic delegate:self];
//}
//
//- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data{
//    NSArray *ridos = [MTLJSONAdapter modelsOfClass:RidoObj.class
//                                     fromJSONArray:[data objectForKey:@"results"] error:nil];
//    if (!ridos) return;
//    NSDictionary *dic = @{@"Rido":ridos};
//    [_audioArr addObject:dic];
//    if ([ridos count]>0) {
//        [self.audioTableView reloadData];
//    }
//    [self showResultTableView];
//}
//
//- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error{
//    UALog(@"error:%@",error);
//}

#pragma mark - segmentedControl Change Value

- (void)segmentedControlChangeValue:(id)sender{
    if (_oldSegmentCount!=self.segmentedControl.selectedSegmentIndex)
        _oldSegmentCount = (int)self.segmentedControl.selectedSegmentIndex;
    else
        return;
    
    if (_oldSegmentCount==0) {
//        [UIView animateWithDuration:0.5 animations:^{
//            [self.playlistView setFrame:CGRectMake(0, aFrame.origin.y,aFrame.size.width , aFrame.size.height)];
//            [self.audioView setFrame:CGRectMake(bFrame.size.width, aFrame.origin.y,bFrame.size.width , bFrame.size.height)];
        //        }completion:^(BOOL finished){
            [self showResultTableView];
//        }];
    }else{
//        [UIView animateWithDuration:0.5 animations:^{
//            [self.playlistView setFrame:CGRectMake(-aFrame.size.width, aFrame.origin.y,aFrame.size.width , aFrame.size.height)];
//            [self.audioView setFrame:CGRectMake(0, aFrame.origin.y,bFrame.size.width , bFrame.size.height)];
//        }completion:^(BOOL finished){
            [self showResultTableView];
//        }];
    }
#if defined(__LP64__) && __LP64__
    UALog(@"changed value is:%ld",self.segmentedControl.selectedSegmentIndex);
#else
    UALog(@"changed value is:%d",self.segmentedControl.selectedSegmentIndex);
#endif
}

#pragma mark add to playlist

-(void)addButtonAction:(NSIndexPath *)aIndexPath{
    NSArray *allValueArr = [[[_audioArr objectAtIndex:aIndexPath.section] allValues] objectAtIndex:0];
    id<ThirdpartyMusicProtocol> thirdpartyMusic = [allValueArr objectAtIndex:aIndexPath.row];
    
//    switch ([thirdpartyMusic source]) {
//        case MusicSourceSoundCloud:
//            UALog(@"-SoundCloud--::name::----:%@",[thirdpartyMusic songName]);
//            break;
//        case MusicSourceSpotify:
//            UALog(@"-Spotify--::name::----:%@",[thirdpartyMusic songName]);
//            break;
//        case MusicSourceRdio:
//            UALog(@"-Rido--::name::----:%@",[thirdpartyMusic songName]);
//            break;
//        default:
//            UALog(@"-iTunes--::name::----:%@",[thirdpartyMusic songName]);
//            break;
//    }

    
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
            _addMusicPlaylistTabelVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addMusicToPlaylistVC"];
            _addMusicPlaylistTabelVC.playlistObjDic=musicDic;
//            UINavigationController *aNavRegist = [[UINavigationController alloc] initWithRootViewController:_addMusicPlaylistTabelVC];
//            [self presentViewController:aNavRegist animated:YES completion:nil];
            [self.navigationController pushViewController:_addMusicPlaylistTabelVC animated:YES];
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

#pragma mark touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
@end
