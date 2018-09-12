//
//  TWMessagingRecipientCell.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWMessageRenderer.h"

@interface TWTextRecipientCell : UITableViewCell <TWMessageRenderer>

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
