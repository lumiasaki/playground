//
//  TWGlobalConfiguration.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWGlobalConfiguration.h"
#import "TWPersistingManager.h"

@implementation TWGlobalConfiguration

+ (instancetype)sharedConfiguration {
    static TWGlobalConfiguration *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWGlobalConfiguration alloc] init];
    });
    return instance;
}

- (TWUser *)currentUser {
    NSSet *currentUsers = [TWPersistingManager.sharedManager selectObjects:TWUser.class predicate:[NSPredicate predicateWithFormat:@"userId = %@", @"currentUserId"]];
    if (currentUsers.count == 1) {
        return currentUsers.anyObject;
    } else {
        TWUser *currentUser = [[TWUser alloc] init];
        currentUser.userId = @"currentUserId";
        currentUser.name = @"currentUser";
        currentUser.screenName = @"currentUserNickName";
        currentUser.profileUrl = @"currentImageUrl";
        currentUser.createTime = [NSDate dateWithTimeIntervalSinceNow:100];
        
        [TWPersistingManager.sharedManager insertObject:currentUser];
        [TWPersistingManager.sharedManager save];
        
        return currentUser;
    }
}

@end
