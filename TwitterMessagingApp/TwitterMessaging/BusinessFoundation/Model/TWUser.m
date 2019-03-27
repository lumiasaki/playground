//
//  TWUser.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWUser.h"
#import "TWUtils.h"

@implementation TWUser

- (void)parseFromDict:(NSDictionary *)dict {
    self.userId = dict[@"id_str"];
    self.name = dict[@"name"];
    self.screenName = dict[@"screen_name"];
    self.createTime = [TWUtils dateWithString:dict[@"create_at"] format:@"E MMM dd HH:mm:ss Z yyyy"];
    self.profileUrl = dict[@"profile_url"];
}

@end
