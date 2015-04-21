//
//  ExploreViewController.m
//  Duorey
//
//  Created by xdy on 14/11/3.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ExploreViewController.h"
#import "GridCollectionViewCell.h"
#import "MainListCollectionReusableView.h"
#import "MainViewCollectionReusableView.h"
#import "MainCollectionViewFlowLayout.h"
#import "BigCollectionViewCell.h"
#import "ListCollectionViewCell.h"
#import "ItunesTableViewController.h"
#import "HotPlaylistViewController.h"
#import "SearchViewController.h"
#import "PTAppClientEngine.h"
#import "UserAccount.h"
#import "PlaylistItunesTableViewController.h"
#import "YLRefresh.h"
#import "UIViewController+Balancer.h"
#import "SongObj.h"
#import "RssAppleMusic.h"

static NSString *const bigCell = @"bigCell";
static NSString *const publishCell = @"publishCell";
static NSString *const listCell = @"listCell";
static NSString * const AllHeaderIdentifier = @"AllHeaderIdentifier";
static NSString * const SectionHeaderIdentifier = @"SectionHeaderIdentifier";


@interface ExploreViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,MainListCollectionReusableViewDeleagte,MainViewCollectionReusableViewDelegate,SearchViewControllerDelegate>{
    NSArray *_newPlaylist;
    NSArray *_hotPlaylist;
    NSArray *_topPlaylist;
    UIButton *_searchBarButton;
}

@property (nonatomic, strong) MainCollectionViewFlowLayout *collectionViewLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, copy) NSURL *topChartImageString;

@end

@implementation ExploreViewController
#pragma mark -

- (UIButton *)searchBarButton{
    if (!_searchBarButton) {
        _searchBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBarButton.backgroundColor = [UIColor clearColor];
        _searchBarButton.tintColor=[UIColor greenColor];
        [_searchBarButton setImage:[UIImage imageNamed:@"searchBar_button_bg"]
                          forState:UIControlStateNormal];
        [_searchBarButton addTarget:self action:@selector(searchButtonAction:)
                   forControlEvents:UIControlEventTouchDown];
    }
    return _searchBarButton;
}

- (UserAccount *)userAccount{
   return [PTUtilities readLoginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self setUpBalancerView];
    self.navigationItem.titleView = self.searchBarButton;
    [self.searchBarButton sizeToFit];
    
    [self loadCollectionView];
    [self performSelector:@selector(indexSetupRefresh) withObject:nil afterDelay:0.5];
}

- (void)indexSetupRefresh{
    [self.collectionView addHeaderWithTarget:self action:@selector(indexDropViewDidBeginRefreshing:) dateKey:@"appIndex"];
    
    if ([PTUtilities isNetWorkConnect]) {
        [self.collectionView headerBeginRefreshing];
    }else{
        _topPlaylist = [PTUtilities unarchiveObjectWithName:@"LastLoadTopPlaylist"];
        _hotPlaylist = [PTUtilities unarchiveObjectWithName:@"LastLoadHotPlaylist"];
        _newPlaylist = [PTUtilities unarchiveObjectWithName:@"LastLoadNewPlaylist"];
        [self.collectionView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in" action:@"in" label:@"T_in" value:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_out" action:@"out" label:@"T_out" value:nil];
}

#pragma mark - refreshing

- (void)indexDropViewDidBeginRefreshing:(id)refreshControl
{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [self userAccount];
    //这里去load首页和topChart的数据
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        [[PTAppClientEngine sharedClient] getMainViewListWithMusicWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                       token:user.userToken
                                                                        page:1
                                                                  completion:^(NSMutableDictionary *valueDic, NSError *error){
                                                                      __strong typeof(self) strongSelf = weakSelf;
                                                                      [strongSelf.collectionView headerEndRefreshing];
                                                                      if (error) {
                                                                          [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                      }else{
                                                                          _hotPlaylist = [MTLJSONAdapter modelsOfClass:MainViewObj.class fromJSONArray:[valueDic objectForKey:@"hot"] error:nil];
                                                                          _topPlaylist = [MTLJSONAdapter modelsOfClass:MainViewObj.class fromJSONArray:[valueDic objectForKey:@"top"] error:nil];
                                                                          _newPlaylist = [MTLJSONAdapter modelsOfClass:MainViewObj.class fromJSONArray:[valueDic objectForKey:@"new"] error:nil];
                                                                          [PTUtilities archiveObject:_hotPlaylist withName:@"LastLoadHotPlaylist"];
                                                                          [PTUtilities archiveObject:_topPlaylist withName:@"LastLoadTopPlaylist"];
                                                                          [PTUtilities archiveObject:_newPlaylist withName:@"LastLoadNewPlaylist"];
                                                                          [strongSelf.collectionView reloadData];
                                                                      }
                                                                  }];

    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        [SongObj getItunesMainValueWithCount:25 completion:^(NSArray *values, NSError *error){
            __strong typeof(self) strongSelf = weakSelf;
            if (error==nil) {
                id<ThirdpartyMusicProtocol> itunesObj = [values firstObject];
                strongSelf.topChartImageString = [itunesObj iconBigURL];
                [strongSelf setTopChartImageViewImage];
            } else {
                
            }
        }];
    });
    
}

//设置topChart的图片

- (void)setTopChartImageViewImage {
    if (self.topChartImageString) {
        ListCollectionViewCell *cell = (ListCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
        if (cell) {
            [cell setMainImageViewWithImageUrlString:self.topChartImageString];
        }
    }
}

- (void)loadCollectionView{
    _collectionViewLayout = [[MainCollectionViewFlowLayout alloc] init];
    
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setCollectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[GridCollectionViewCell class]
        forCellWithReuseIdentifier:publishCell];
    [_collectionView registerClass:[BigCollectionViewCell class]
        forCellWithReuseIdentifier:bigCell];
    [_collectionView registerClass:[ListCollectionViewCell class]
        forCellWithReuseIdentifier:listCell];
    [_collectionView registerClass:[MainViewCollectionReusableView class]
        forSupplementaryViewOfKind:MainCollectionViewAllViewHeaderKind
               withReuseIdentifier:AllHeaderIdentifier];
    [_collectionView registerClass:[MainListCollectionReusableView class]
        forSupplementaryViewOfKind:MainCollectionViewSectionHeaderKind
               withReuseIdentifier:SectionHeaderIdentifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchButtonAction:(id)sender{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_Search" action:@"Click_search" label:@"search" value:nil];
    
//    SearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchVC"];
//    searchVC.delegate=self;
    UINavigationController *nav = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"searchVCNVC"];
    SearchViewController *searchVC  = [[nav viewControllers] firstObject];
    searchVC.delegate=self;
    searchVC.hidesBottomBarWhenPushed = YES;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
//    [self presentViewController:nav animated:YES completion:nil];
    [self.navigationController pushViewController:searchVC animated:NO];
}

#pragma mark tableview delegate and datasouce
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}

//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section==0) return 0;
    else if (section==2) return 1;
    
    return 6;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        MainViewObj *mainViewObj;
        if ([_hotPlaylist count]>indexPath.row) {
            mainViewObj = [_hotPlaylist objectAtIndex:indexPath.row];
        }
        if (indexPath.row==0) {
            BigCollectionViewCell *cell = (BigCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:bigCell
                                                                                                               forIndexPath:indexPath];
            if ([_hotPlaylist count]>0) {
                [cell setMainImageViewWithImageUrl:[NSURL URLWithString:mainViewObj.listIcon]];
                [cell setNameLabelWithStr:mainViewObj.listName];
                [cell setCountLabelWithStr:[NSString stringWithFormat:@"%@",mainViewObj.listenCount]];
            }
            [cell setNoImageViewWithImageName:@"No.1"];
            return cell;
        }
        
        GridCollectionViewCell *cell = (GridCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:publishCell
                                                                                                           forIndexPath:indexPath];
        [cell setNoCountImageViewHidden:YES];
        NSString *noStr = @"";
        if (indexPath.row==1) {
            noStr = @"No.2";
            [cell setNoCountImageViewHidden:NO];
        }else if (indexPath.row==2){
            noStr = @"No.3";
            [cell setNoCountImageViewHidden:NO];
        }
        if ([_hotPlaylist count]>0) {
            [cell setMainImageViewWithImageUrl:[NSURL URLWithString:mainViewObj.listIcon]];
            [cell setNameLabelWithStr:mainViewObj.listName];
            [cell setCountLabelWithStr:[NSString stringWithFormat:@"%@",mainViewObj.listenCount]];
        }
        [cell setNoImageViewWithImageName:noStr];
        return cell;
    }else if(indexPath.section==2){
        ListCollectionViewCell *cell = (ListCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:listCell
                                                                                                        forIndexPath:indexPath];
        [cell setMainImageViewWithImageName:@"icon_top"];
        if (self.topChartImageString) {
            [cell setMainImageViewWithImageUrlString:self.topChartImageString];
        }
        [cell setNameLabelWithStr:PTNSLocalizedString(@"iTunesMsgKey", nil)];
        [cell setSubNameLabelWithStr:PTNSLocalizedString(@"itunesTopListMsgKey", nil)];

        return cell;
    }else if(indexPath.section==3){
        MainViewObj *mainViewObj;
        if ([_newPlaylist count]>0 && [_newPlaylist count]>indexPath.row) {
            mainViewObj = [_newPlaylist objectAtIndex:indexPath.row];
        }
        GridCollectionViewCell *cell = (GridCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:publishCell
                                                                                                           forIndexPath:indexPath];
        if ([_newPlaylist count]>0 && [_newPlaylist count]>indexPath.row) {
            [cell setMainImageViewWithImageUrl:[NSURL URLWithString:mainViewObj.listIcon]];
            [cell setNameLabelWithStr:mainViewObj.listName];
            [cell setCountLabelWithStr:[NSString stringWithFormat:@"%@",mainViewObj.listenCount]];
            [cell setNoCountImageViewHidden:YES];
        }
        return cell;
    }
    return nil;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MainViewObj *mainViewObj;
    if (indexPath.section==0){
        if([_topPlaylist count]<=indexPath.row) return;
        
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_top" action:@"Click_top" label:@"top_playlist" value:nil];
        
        mainViewObj = [_topPlaylist objectAtIndex:indexPath.row];
        
        PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
        playlistItunesVC.listId = [NSString stringWithFormat:@"%@",mainViewObj.listId];
        playlistItunesVC.whereF = @"topview";
        playlistItunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:playlistItunesVC animated:YES];
    }else if (indexPath.section==1){
        if([_hotPlaylist count]<=indexPath.row) return;
        
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_hot_playlist" action:@"Click_hot" label:@"hot_playlist" value:nil];
        
        mainViewObj = [_hotPlaylist objectAtIndex:indexPath.row];
        
        PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
        playlistItunesVC.listId = [NSString stringWithFormat:@"%@",mainViewObj.listId];
        playlistItunesVC.whereF = @"hot";
        playlistItunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:playlistItunesVC animated:YES];
    }else if(indexPath.section==2){
        ItunesTableViewController *itunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"iTunesVC"];
        itunesVC.listId = [mainViewObj.listId intValue];
        itunesVC.whereF=@"Itunes";
        itunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:itunesVC animated:YES];
    }else if(indexPath.section==3){
        if([_newPlaylist count]<=indexPath.row) return;
        
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_new_playlist" action:@"Click_new" label:@"new_playlist" value:nil];
        
        mainViewObj = [_newPlaylist objectAtIndex:indexPath.row];
        
        PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
        playlistItunesVC.listId = [NSString stringWithFormat:@"%@",mainViewObj.listId];
        playlistItunesVC.whereF = @"new";
        playlistItunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:playlistItunesVC animated:YES];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionReusableView *titleView = nil;
    
    if ([kind isEqualToString: MainCollectionViewAllViewHeaderKind]) {
        titleView = (MainViewCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                         withReuseIdentifier:AllHeaderIdentifier
                                                                                                forIndexPath:indexPath];
        [(MainViewCollectionReusableView *)titleView setImageViewWithImage:(NSMutableArray *)_topPlaylist];
        [(MainViewCollectionReusableView *)titleView setDelegate:self];
    }
    else if (kind == MainCollectionViewSectionHeaderKind) {
        NSString *iconName = @"";
        NSString *nameStr = @"";
        if (indexPath.section==1) {
            iconName = @"icon_hot";
            nameStr = PTNSLocalizedString(@"HotPlaylistsMsgKey", nil);
        }else if(indexPath.section==2){
            iconName = @"top_icon";
            nameStr = PTNSLocalizedString(@"TopChartMsgKey", nil);
        }else if(indexPath.section==3){
            iconName = @"ion_new";
            nameStr = PTNSLocalizedString(@"NewPlaylistMsgKey", nil);
        }
        
        titleView = (MainListCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                         withReuseIdentifier:SectionHeaderIdentifier
                                                                                                forIndexPath:indexPath];
        [((MainListCollectionReusableView *)titleView) setNameLabelWithNaemStr:nameStr];
        [((MainListCollectionReusableView *)titleView) setIconImageWithImageName:iconName];
        [((MainListCollectionReusableView *)titleView) setDelegate:self];
        ((MainListCollectionReusableView *)titleView).aTag = (int)indexPath.section;
        if (indexPath.section == 2) {
            [((MainListCollectionReusableView *)titleView) setMoreButtonHidden:YES];
            [((MainListCollectionReusableView *)titleView) setJianTouHidden:YES];
        } else {
            [((MainListCollectionReusableView *)titleView) setMoreButtonHidden:NO];
            [((MainListCollectionReusableView *)titleView) setJianTouHidden:NO];
        }
    }
    
    return titleView;
}

- (void)moreButtonAction:(int)aTag{
    UALog(@"click more");
    HotPlaylistViewController *hotVC = [self.storyboard instantiateViewControllerWithIdentifier:@"hotPlaylistVC"];
    if (aTag == 1) {
        hotVC.whereF = @"hot";
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_hot_playlist" action:@"Click_hot_more" label:@"hot_playlist_more" value:nil];
    } else if (aTag == 2) {
        ItunesTableViewController *itunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"iTunesVC"];
        itunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:itunesVC animated:YES];
    } else if (aTag == 3) {
        hotVC.whereF = @"new";
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_new_playlist" action:@"Click_new_more" label:@"new_playlist_more" value:nil];
    }
    hotVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:hotVC animated:YES];
}

- (void)clickImageViewCount:(int)imageViewCount{
    [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_manual" action:@"Click_manual" label:@"manual" value:nil];
    MainViewObj *mainViewObj = [_topPlaylist objectAtIndex:imageViewCount];
    
    PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
    playlistItunesVC.listId = [NSString stringWithFormat:@"%@",mainViewObj.listId];
    playlistItunesVC.whereF=@"topView";
    playlistItunesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:playlistItunesVC animated:YES];
}
#pragma mark - push
- (void)pushToSearchViewC:(id)sender{
//    SearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchVC"];
}

- (void)creatPlaylistBack{
    
}

@end
