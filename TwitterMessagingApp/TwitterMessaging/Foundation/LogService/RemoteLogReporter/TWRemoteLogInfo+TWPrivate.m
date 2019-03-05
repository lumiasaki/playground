//
//  TWRemoteLogInfo+TWPrivate.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWRemoteLogInfo+TWPrivate.h"
#import <objc/runtime.h>

@implementation TWRemoteLogInfo (TWPrivate)

- (void)setTw_associatedFileName:(NSString *)tw_associatedFileName {
    objc_setAssociatedObject(self, @selector(tw_associatedFileName), tw_associatedFileName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)tw_associatedFileName {
    return objc_getAssociatedObject(self, _cmd);
}

@end
