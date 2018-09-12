//
//  TWMessage.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWMessage.h"

@implementation TWMessage

- (void)renderInRenderer:(id<TWMessageRenderer>)renderer {
    NSAssert(NO, @"abstract method, subclass override");
}

@end
