//
//  TWTextMessage.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWMessage.h"

// a text message indicates a message which the message type is TWPlainTextMessageType
@interface TWTextMessage : TWMessage

@property (nonatomic, strong) NSString *textMessageContent;

@end
