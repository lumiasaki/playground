//
//  TWMessagingAction.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWMessagingViewController.h"

@interface TWMessagingAction : NSObject <UITextFieldDelegate>

@property (nonatomic, weak, readonly) TWMessagingViewController *viewController;

- (instancetype)initWithViewController:(TWMessagingViewController *)viewController;

- (void)requestMessagesFromRemote;
- (void)sendMessage;

@end
