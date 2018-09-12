//
//  TWFollowerListViewController.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWDialogue.h"

@interface TWFollowerListViewController : UIViewController

- (void)renderDialogues:(NSArray<TWDialogue *> *)dialogues;
- (void)displayNetworkErrorAlert;

@end

