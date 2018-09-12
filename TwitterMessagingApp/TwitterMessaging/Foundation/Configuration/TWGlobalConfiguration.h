//
//  TWGlobalConfiguration.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWUser.h"

@interface TWGlobalConfiguration : NSObject

@property (nonatomic, strong) TWUser *currentUser;

+ (instancetype)sharedConfiguration;

@end
