//
//  TWFollowerListViewModel.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWFollowerListViewController.h"

@interface TWFollowerListAction : NSObject

@property (nonatomic, weak, readonly) TWFollowerListViewController *viewController;

- (instancetype)initWithViewController:(TWFollowerListViewController *)viewController;

- (void)changeCurrentUserWith:(NSString *)userId;
- (void)fetchFollowers;

@end
