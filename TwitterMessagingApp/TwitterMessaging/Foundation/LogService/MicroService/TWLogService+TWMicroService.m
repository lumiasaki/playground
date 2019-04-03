//
//  TWLogService+TWMicroService.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/4/2.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWLogService+TWMicroService.h"
#import "TWLogConsolePrinter.h"
#import "TWRemoteLogReporter.h"

@implementation TWLogService (TWMicroService)

+ (NSString *)serviceKey {
    return NSStringFromClass(self);
}

+ (TWMicroServiceIsolateLevel)isolateLevel {
    return TWMicroServiceIsolateGlobalLevel;
}

+ (TWMicroServiceInitializeLevel)initializeLevel {
    return TWMicroServiceInitializeLazyLevel;
}

#pragma mark - TWMicroServiceLifeCycle

- (void)start {
    [self registerObserver:[[TWLogConsolePrinter alloc] init] onLevel:TWLogLevelAll];
    [self registerObserver:[[TWRemoteLogReporter alloc] init] onLevel:TWLogLevelError | TWLogLevelFatal];
    
    [self setUpDone];
}

@end
