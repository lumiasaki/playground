//
//  TWMessage.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWBaseModel.h"
#import "TWUser.h"
#import "TWMessageRenderer.h"

typedef NS_ENUM(NSInteger, TWMessageType) {
    TWPlainTextMessageType = 1
};

// a message indicates a message entity in the app, it involves messaging peer, timestamp, read status, and the content of message ( should be provided by subclass )
@interface TWMessage : TWBaseModel

@property (nonatomic, strong) TWUser *sender;
@property (nonatomic, strong) TWUser *receiver;
@property (nonatomic, strong) NSNumber *messageType;    // associated with TWMessageType value
@property (nonatomic, strong) NSDate *timestamp;  // timestamp with unix time format
@property (nonatomic, strong) NSNumber *readStatus;
@property (nonatomic, strong) NSString *messageUniqueIdentifier;

// for flexibility reasons, a message knows how to render itself by renderer, but it's difficult when it be reversed, because a renderer is difficult to know everything of messages, if there is a new type of message in the future, the renderer must be modified to adapt new message modes. but if renderer only declare the abilities about itself, message could adapt the UI things easily, because message know every detail of itself.
- (void)renderInRenderer:(id<TWMessageRenderer>)renderer;

@end
