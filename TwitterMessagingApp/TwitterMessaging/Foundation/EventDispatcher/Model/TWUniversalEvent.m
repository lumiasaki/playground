//
//  TWUniversalEvent.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWUniversalEvent.h"

@implementation TWUniversalEvent

- (instancetype)init {
    if (self = [super init]) {
        _timestamp = NSDate.date.timeIntervalSince1970;
    }
    return self;
}

@end
