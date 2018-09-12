//
//  TWMessagingRecipientCell.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWTextRecipientCell.h"

@implementation TWTextRecipientCell

- (void)renderPlainText:(NSString *)text {
    self.contentLabel.text = text;
}

- (void)renderTimestamp:(NSString *)timestamp {
    self.timeLabel.text = timestamp;
}

@end
