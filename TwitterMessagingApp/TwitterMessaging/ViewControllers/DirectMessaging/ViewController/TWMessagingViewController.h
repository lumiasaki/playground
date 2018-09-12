//
//  TWMessagingViewController.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWMessage.h"
#import "TWDialogue.h"

@interface TWMessagingViewController : UIViewController

@property (nonatomic, strong, readonly) TWDialogue *dialogue;

- (void)renderMessages:(NSArray<TWMessage *> *)messages;

@end
