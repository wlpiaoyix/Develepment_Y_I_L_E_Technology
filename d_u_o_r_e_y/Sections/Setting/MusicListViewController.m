//
//  MusicListViewController.m
//  Duorey
//
//  Created by xdy on 14/11/26.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "MusicListViewController.h"
#import "MusicListCell.h"
#import "Music.h"
#import "UIImageView+WebCache.h"
#import "YLAudioPlayer.h"
#import "PTUtilities.h"
#import "PTConstant.h"

@interface MusicListViewController ()
{

}
@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    [self.tableView registerNib:[UINib nibWithNibName:[MusicListCell xibName] bundle:nil] forCellReuseIdentifier:[MusicListCell reuseIdentifier]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.musics count];
}

/**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:[MusicListCell reuseIdentifier] forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:[MusicListCell reuseIdentifier] owner:self options:nil] lastObject];
    }
    
    // Configure the cell...
    Music *mu = [self.musics objectAtIndex:indexPath.row];
    if (mu.artworkUrlBigger != nil) {
        [cell.musicImageView sd_setImageWithURL:mu.artworkUrlBigger placeholderImage:[UIImage imageNamed:@"DefaultCoverActivity"]];
    }
    [cell.balancerView setSomething:mu];
    cell.musicNameLabel.text = mu.trackName;
    
    NSString *artistName = mu.artistName;
    if (mu.artistName ==nil || [mu.artistName isEmpty]) {
        artistName = PTNSLocalizedString(@"UnknowMsgKey", nil);
    }
    
    NSString *albumName = mu.albumName;
    if (mu.albumName ==nil || [mu.albumName isEmpty]) {
        albumName = PTNSLocalizedString(@"UnknowMsgKey", nil);
    }
    
    cell.musicDetailLabel.text = [NSString stringWithFormat:@"%@·%@",artistName,albumName];
    switch (mu.source) {
        case MusicSourceSoundCloud:
            cell.musicSourceImageView.image = [UIImage imageNamed:@"cellMusicSoundCloud"];
            break;
        default:
            cell.musicSourceImageView.image = [UIImage imageNamed:@"cellMusicTunes"];
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[YLAudioPlayer sharedAudioPlayer] playTracks:_musics startIndex:indexPath.row];
//    postNotification(MusicPlayCellPlayViewStartingNotification, nil, nil);
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MusicListCell cellHeight];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
