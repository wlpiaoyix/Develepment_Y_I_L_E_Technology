//
//  HistoryTableViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HistoryTableViewCellDelegate <NSObject>

- (void)deleteSearchKey:(NSInteger)aIndexPathRow;

@end

@interface HistoryTableViewCell : UITableViewCell

@property (strong, nonatomic) id<HistoryTableViewCellDelegate> delegate;

@property (nonatomic) NSInteger aIndexPathRow;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)deleteButtonAction:(id)sender;
@end
