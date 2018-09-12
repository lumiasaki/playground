//
//  TWUser.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TWBaseModel.h"
@class TWMessage;

// a user represents a user in twitter, it has unique userId and some other useful information, if needed, it could be defined as same as the user object model of Twitter
@interface TWUser : TWBaseModel

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileUrl;
@property (nonatomic, strong) NSDate *createTime;

- (void)parseFromDict:(NSDictionary *)dict;

@end
