//
//  HotPlaylistViewController.m
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "HotPlaylistViewController.h"
#import "GridCollectionViewCell.h"
#import "PTAppClientEngine.h"
#import "UserAccount.h"
#import "PTUtilities.h"
#import "ItunesTableViewController.h"
#import "PlaylistItunesTableViewController.h"
#import "YLRefresh.h"
#import "UIViewController+Balancer.h"

static NSString *const collectionCell = @"collectionCell";

@interface HotPlaylistViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableArray *_hotPlaylist;
    NSMutableArray *_newPlaylist;
    NSMutableArray *_otherUserPlaylist;
    int _pageCount;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HotPlaylistViewController

- (UserAccount *)userAccount{
    return [PTUtilities readLoginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    // Do any additional setup after loading the view.
    
    [self setUpBalancerView];
    
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView registerClass:[GridCollectionViewCell class]
        forCellWithReuseIdentifier:collectionCell];
    [self setupRefresh];
}

- (void)setupRefresh{
    [self.collectionView addHeaderWithTarget:self action:@selector(dropViewDidBeginRefreshing:) dateKey:@"hotPlaylists"];
    if ([PTUtilities isNetWorkConnect]) {
        [self.collectionView headerBeginRefreshing];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([self.whereF isEqualToString:@"new"]) {
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_hot_playlist_1" action:@"out" label:@"T_in_manul_1_out" value:nil];
    }else{
        [PTUtilities sendGaTrackingWithScreenName:nil category:@"T_in_new_playlist_1" action:@"out" label:@"T_in_manul_1_out" value:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.whereF isEqualToString:@"new"]){
        self.navigationItem.title = PTNSLocalizedString(@"NewPlaylistMsgKey", nil);
    }else if ([self.whereF isEqualToString:@"hot"]){
        self.navigationItem.title = PTNSLocalizedString(@"HotPlaylistsMsgKey", nil);
    }else{
        if (self.otherUserId) {
            self.navigationItem.title = PTNSLocalizedString(@"FeededPlaylistTitleMsgKey", nil);
        }else{
            self.navigationItem.title = PTNSLocalizedString(@"NormalPlaylistKey", nil);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.otherUserId) {
        return [_otherUserPlaylist count];
    }
    if ([self.whereF isEqualToString:@"new"]) {
        return [_newPlaylist count];
    }
    return [_hotPlaylist count];
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.otherUserId) {
        PlaylistObj *playlist = [_otherUserPlaylist objectAtIndex:indexPath.row];
        GridCollectionViewCell *cell = (GridCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCell
                                                                                                           forIndexPath:indexPath];
        [cell setMainImageViewWithImageUrl:[NSURL URLWithString:playlist.listIcon]];
        [cell setNameLabelWithStr:playlist.listName];
        [cell setCountLabelWithStr:[NSString stringWithFormat:@"%@",playlist.listenNum]];
        return cell;
    }else{
        MainViewObj *obj;
        if ([self.whereF isEqualToString:@"new"]) {
            if ([_newPlaylist count]>0) {
                obj = [_newPlaylist objectAtIndex:indexPath.row];
            }
        }else{
            if ([_hotPlaylist count]>0) {
                obj = [_hotPlaylist objectAtIndex:indexPath.row];
            }
        }
        GridCollectionViewCell *cell = (GridCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCell
                                                                                                           forIndexPath:indexPath];
        
        int valueCount = 0;
        if ([self.whereF isEqualToString:@"new"]) {
            valueCount = (int)[_newPlaylist count];
        }else{
            valueCount = (int)[_hotPlaylist count];
        }
        if (valueCount>0) {
            [cell setMainImageViewWithImageUrl:[NSURL URLWithString:obj.listIcon]];
            [cell setNameLabelWithStr:obj.listName];
            [cell setCountLabelWithStr:[NSString stringWithFormat:@"%@",obj.listenCount]];
        }
        return cell;
    }
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float aWith = (_collectionView.frame.size.width-50)/3;
    return CGSizeMake(aWith, aWith+30);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.otherUserId){
        PlaylistObj *playlist = [_otherUserPlaylist objectAtIndex:indexPath.row];
        PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
        playlistItunesVC.listId = [NSString stringWithFormat:@"%@",playlist.listId];
        playlistItunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:playlistItunesVC animated:YES];
    }else{
        PlaylistItunesTableViewController *playlistItunesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistItunesVC"];
        MainViewObj *obj;
        if ([self.whereF isEqualToString:@"new"]) {
            playlistItunesVC.whereF=@"new";
            if ([_newPlaylist count]>0) {
                obj = [_newPlaylist objectAtIndex:indexPath.row];
            }
        }else{
            playlistItunesVC.whereF=@"hot";
            if ([_hotPlaylist count]>0) {
                obj = [_hotPlaylist objectAtIndex:indexPath.row];
            }
        }
        playlistItunesVC.listId = [NSString stringWithFormat:@"%@",obj.listId];
        playlistItunesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:playlistItunesVC animated:YES];
    }

}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - refresh
- (void)dropViewDidBeginRefreshing:(id)refreshControl
{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [self userAccount];
    if (self.otherUserId) {
        [[PTAppClientEngine sharedClient] getOtherPlaylistAndFollowlistWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                            token:user.userToken
                                                                     targetUserId:[NSString stringWithFormat:@"%@",self.otherUserId]
                                                                             page:1
                                                                       completion:^(NSArray *playlists, NSError *error) {
                                                                           __strong typeof(self) strongSelf = weakSelf;
                                                                           [strongSelf.collectionView headerEndRefreshing];
                                                                           if (!error) {
                                                                               if ([playlists count]>0) {
                                                                                   _otherUserPlaylist=(NSMutableArray *)playlists;
                                                                                   [strongSelf.collectionView removeFooter];
                                                                                   [strongSelf.collectionView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                                                   _pageCount=2;
                                                                               }else{
                                                                                   if (_otherUserPlaylist) {
                                                                                       [_otherUserPlaylist removeAllObjects];
                                                                                   }
                                                                               }
                                                                               [_collectionView reloadData];
                                                                           }else{
                                                                               [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                           }
                                                                       }];
    }else{
        NSString *typeStr = @"H";
        if ([self.whereF isEqualToString:@"new"]) {
            typeStr = @"N";
        }
        [[PTAppClientEngine sharedClient] getMainViewListMoreWithMusicWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                           token:user.userToken
                                                                            type:typeStr
                                                                            page:1
                                                                      completion:^(NSArray *valueDic, NSError *error){
                                                                      __strong typeof(self) strongSelf = weakSelf;
                                                                      [strongSelf.collectionView headerEndRefreshing];
                                                                      if (error) {
                                                                          [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                      }else{
                                                                          if ([self.whereF isEqualToString:@"new"]) {
                                                                              if([valueDic count]>0){
                                                                                  _newPlaylist = (NSMutableArray *)valueDic;
                                                                                  _pageCount=2;
                                                                                  [self.collectionView removeFooter];
                                                                                  [self.collectionView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                                                  [_collectionView reloadData];
                                                                              }else{
                                                                                  if (_newPlaylist) {
                                                                                      [_newPlaylist removeAllObjects];
                                                                                  }
                                                                              }
                                                                          }else{
                                                                              if ([valueDic count]>0) {
                                                                                  _hotPlaylist = (NSMutableArray *)valueDic;
                                                                                  _pageCount=2;
                                                                                  [self.collectionView removeFooter];
                                                                                  [self.collectionView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                                                  [_collectionView reloadData];
                                                                              }else{
                                                                                  if (_hotPlaylist) {
                                                                                      [_hotPlaylist removeAllObjects];
                                                                                  }
                                                                              }
                                                                          }

                                                                      }
                                                                  }];
    }
}

- (void)upViewDidBeginRefreshingFollow:(id)sender{
    __weak typeof(self) weakSelf = self;
    //获取数据的
    UserAccount *user = [self userAccount];
    if (self.otherUserId) {
        [[PTAppClientEngine sharedClient] getOtherPlaylistAndFollowlistWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                            token:user.userToken
                                                                     targetUserId:[NSString stringWithFormat:@"%@",self.otherUserId]
                                                                             page:_pageCount
                                                                       completion:^(NSArray *playlists, NSError *error) {
                                                                           __strong typeof(self) strongSelf = weakSelf;
                                                                           if (!error) {
                                                                               if ([playlists count]>0) {
                                                                                   [_otherUserPlaylist addObjectsFromArray:playlists];
                                                                                   _pageCount++;
                                                                                   [_collectionView reloadData];
                                                                                   [strongSelf.collectionView endLoadMoreRefreshing];
                                                                               }else{
                                                                                   [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                                   [strongSelf.collectionView endMoreOverWithMessage:@""];
                                                                               }
                                                                           }else{
                                                                               [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                           }
                                                                       }];
    }else{
        NSString *typeStr = @"H";
        if ([self.whereF isEqualToString:@"new"]) {
            typeStr = @"N";
        }
        [[PTAppClientEngine sharedClient] getMainViewListMoreWithMusicWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                           token:user.userToken
                                                                            type:typeStr
                                                                            page:_pageCount
                                                                      completion:^(NSArray *valueDic, NSError *error){
                                                                      __strong typeof(self) strongSelf = weakSelf;
                                                                      if (error) {
                                                                          [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                      }else{
                                                                          if ([self.whereF isEqualToString:@"new"]) {
                                                                              if ([valueDic count]>0) {
                                                                                  [_newPlaylist addObjectsFromArray:valueDic];
                                                                                  _pageCount++;
                                                                                  [strongSelf.collectionView reloadData];
                                                                                  [strongSelf.collectionView endLoadMoreRefreshing];
                                                                              }else{
                                                                                  [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                                  [strongSelf.collectionView endMoreOverWithMessage:@""];
                                                                              }
                                                                          }else{
                                                                              if ([valueDic count]>0) {
                                                                                  [_hotPlaylist addObjectsFromArray:valueDic];
                                                                                  _pageCount++;
                                                                                  [strongSelf.collectionView reloadData];
                                                                                  [strongSelf.collectionView endLoadMoreRefreshing];
                                                                              }else{
                                                                                  [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                                  [strongSelf.collectionView endMoreOverWithMessage:@""];
                                                                              }
                                                                          }
                                                                      }
                                                                  }];
    }

}
@end
