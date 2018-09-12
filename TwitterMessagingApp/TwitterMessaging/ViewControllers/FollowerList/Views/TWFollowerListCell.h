//
//  TWFollowerListCell.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWFollowerListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentPreviewLabel;

@end
