//
//  AddMusicToPlaylistViewController.m
//  Duorey
//
//  Created by lixu on 14/11/20.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "AddMusicToPlaylistViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "PTDefinitions.h"
#import "PTAppClientEngine.h"
#import "PTConstant.h"
#import "PlaylistViewTableViewCell.h"
#import "NewPlaylistSetNameViewController.h"
#import "UserAccount.h"
#import "UIImageView+WebCache.h"
#import "AddMusicPlaylistTableViewCell.h"
#import "YLRefresh.h"

#define ADD_TO_PLAYLIST_CELL @"aPlaylistCell"

@interface AddMusicToPlaylistViewController ()<UITableViewDataSource,UITableViewDelegate,NewPlaylistSetNameViewControllerDelegate>{
    int _pageCount;
}


@property ( nonatomic) NSMutableArray *playlistArr;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@end

@implementation AddMusicToPlaylistViewController
@synthesize delegate=delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    self.navigationItem.title = PTNSLocalizedString(@"AddToPlaylistTitleMsgKey", nil);
    _listTableView.dataSource=self;
    _listTableView.delegate=self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _pageCount=2;
    if (self.playlistObjDic) {
        [self.listTableView addHeaderWithTarget:self action:@selector(dropViewDidBeginRefreshing:)];
        [self.listTableView headerBeginRefreshing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropViewDidBeginRefreshing:(id)sender{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [PTUtilities readLoginUser];
    [[PTAppClientEngine sharedClient] getPlaylistAndFollowlistWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                   token:user.userToken
                                                                    page:1
                                                              completion:^(NSArray *playlists, NSError *error) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                  [strongSelf.listTableView headerEndRefreshing];
                                                                  if (!error) {
                                                                      if ([playlists count]>0) {
                                                                          _playlistArr=(NSMutableArray *)playlists;
                                                                          [self.listTableView removeFooter];
                                                                          [self.listTableView addFooterWithTarget:self action:@selector(upViewDidBeginRefreshingFollow:)];
                                                                      }else{
                                                                          if (_playlistArr) {
                                                                              [_playlistArr removeAllObjects];
                                                                          }
                                                                      }
                                                                      [_listTableView reloadData];
                                                                  }else{
                                                                      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                  }
                                                              }];
}

- (void)upViewDidBeginRefreshingFollow:(id)sender{
    __weak typeof(self) weakSelf = self;
    UserAccount *user = [PTUtilities readLoginUser];
    [[PTAppClientEngine sharedClient] getPlaylistAndFollowlistWithUserId:[NSString stringWithFormat:@"%@",user.userId]
                                                                   token:user.userToken
                                                                    page:_pageCount
                                                              completion:^(NSArray *playlists, NSError *error) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                  if (!error) {
                                                                      if ([playlists count]>0) {
                                                                          [_playlistArr addObjectsFromArray:playlists];
                                                                          [_listTableView reloadData];
                                                                          _pageCount++;
                                                                          [self.listTableView endLoadMoreRefreshing];
                                                                      }else{
                                                                          [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"NoMoreDataPromptMsgKey", nil)];
                                                                          [strongSelf.listTableView endMoreOverWithMessage:@""];
                                                                      }
                                                                  }else{
                                                                      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                  }
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
    AddMusicPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADD_TO_PLAYLIST_CELL
                                                                      forIndexPath:indexPath];
    if (cell==nil) {
        cell = [[AddMusicPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:ADD_TO_PLAYLIST_CELL];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PlaylistObj *playlist = [_playlistArr objectAtIndex:indexPath.row];
    if (![PTUtilities isEmptyOrNull:playlist.listIcon]) {
        [cell.mainImageView sd_setImageWithURL:[NSURL URLWithString:playlist.listIcon]
                              placeholderImage:[UIImage imageNamed:@"DefaultPlaylistCover"]];
        
    }else{
        UIImage *image = [UIImage imageNamed:@"DefaultPlaylistCover"];
        [cell.mainImageView setImage:image];
    }
    NSString *listName = playlist.listName;
    NSString *totaleNumStr = [NSString stringWithFormat:@"%d songs",[playlist.totalNum intValue]];
    NSString *listStr = [NSString stringWithFormat:PTNSLocalizedString(@"PlaylistCellCountMsgKey", nil),listName,[playlist.totalNum intValue]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:listStr];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"HelveticaNeue-light" size:14]
                       range:NSMakeRange([listStr length]-[totaleNumStr length], [totaleNumStr length])];
    [cell.countLabel setAttributedText:attrString];
//    cell.countLabel.text = [NSString stringWithFormat:PTNSLocalizedString(@"PlaylistCellCountMsgKey", nil),playlist.listName,[playlist.totalNum intValue]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [SVProgressHUD showWithStatus:PTNSLocalizedString(@"AddToPlaylistTitleMsgKey", nil) maskType:SVProgressHUDMaskTypeBlack];
    PlaylistObj *playlistObj = [_playlistArr objectAtIndex:indexPath.row];
    UserAccount *user = [PTUtilities readLoginUser];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *str = [PTUtilities dictionaryToJson:self.playlistObjDic];
    [dic setObject:str forKey:@"data"];
    [dic setObject:playlistObj.listId forKey:@"lid"];
    [dic setObject:[NSString stringWithFormat:@"%@",user.userId] forKey:@"uid"];
    [dic setObject:user.userToken forKey:@"token"];
    [[PTAppClientEngine sharedClient] addOneMusicToHaveListWithMusicDic:dic
                                                             completion:^(NSError *error){
                                                                 if (!error) {
                                                                     [SVProgressHUD showSuccessWithStatus:PTNSLocalizedString(@"MusicAddToPlaylistOKMsgKey", nil)];
                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                 }else{
                                                                     [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                                                                 }
                                                             }];
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
- (IBAction)addMusicCancelButtonAction:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)newPlaylistButtonAction:(id)sender{
    NewPlaylistSetNameViewController *newPlaylistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newPlaylistVC"];
    newPlaylistVC.whereF = @"searchMusic";
    newPlaylistVC.musicDic = self.playlistObjDic;
    newPlaylistVC.delegate = self;
    [self.navigationController pushViewController:newPlaylistVC animated:YES];
}

- (void)doDismissView{
//    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
