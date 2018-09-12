//
//  TWMessagingHostCell.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWTextMessageHostCell.h"

@implementation TWTextMessageHostCell

- (void)renderPlainText:(NSString *)text {
    self.contentLabel.text = text;
}

- (void)renderTimestamp:(NSString *)timestamp {
    self.timeLabel.text = timestamp;
}

- (void)renderReadStatus:(BOOL)read {
    self.readStatusLabel.text = read ? @"read" : @"unread";
}

@end
