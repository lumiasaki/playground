//
//  TWSceneBoxLoggerExtension.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/26.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxLoggerExtension.h"
#import "TWSceneBoxNavigationExtensionConstants.h"
#import "TWSceneBoxSharedStateExtensionConstants.h"
#import "TWSceneBoxEventBus.h"

@implementation TWSceneBoxLoggerExtension

@synthesize eventBus = _eventBus;

- (instancetype)init {
    if (self = [super init]) {
        _printBoxActivitiesToConsole = YES;
        _printNavigationTrackToConsole = YES;
        _printSharedStateChangesToConsole = YES;
    }
    return self;
}

#pragma mark - TWSceneBoxExtension

- (TWSceneBoxExtensionType)extensionType {
    return TWSceneBoxExtensionTypeLogger;
}

#pragma mark - TWSceneBoxExtensionLifeCycle

- (void)extensionDidMount:(TWSceneBox *)sceneBox {
    __weak typeof(self) weakSelf = self;
    [self.eventBus watchEvent:TWSceneBoxNavigationTrackEvent next:^(NSDictionary *event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![event isKindOfClass:NSDictionary.class] || !strongSelf.printNavigationTrackToConsole) {
            return;
        }
        
        NSNumber *from = event[TWSceneBoxNavigationTrackEventFromKey];
        NSNumber *to = event[TWSceneBoxNavigationTrackEventToKey];
        
        [strongSelf logEvent:TWSceneBoxNavigationTrackEvent infoString:[NSString stringWithFormat:@"scene is navigate from: %@, to: %@", from, to]];
    }];
    
    [self.eventBus watchEvent:TWSceneBoxSharedStateChangesEvent next:^(NSDictionary *event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![event isKindOfClass:NSDictionary.class] || !strongSelf.printSharedStateChangesToConsole) {
            return;
        }
        
        NSObject *key = event[TWSceneBoxExtensionEventBusEventObjectKey];
        NSObject *value = event[TWSceneBoxExtensionEventBusEventObjectValueKey];
        
        if ([key respondsToSelector:@selector(debugDescription)] && [value respondsToSelector:@selector(debugDescription)]) {
            [strongSelf logEvent:TWSceneBoxSharedStateChangesEvent infoString:[NSString stringWithFormat:@"shared state changed:\n key: %@, value: %@", key.debugDescription, value.debugDescription]];
        }
    }];
}

#pragma mark - TWSceneBoxLifeCycle

- (void)sceneBoxWillTerminate {
    if (!self.printBoxActivitiesToConsole) {
        return;
    }
    
    [self logEvent:nil infoString:@"scene box will terminate"];
}

#pragma mark - private

- (void)logEvent:(nullable TWSceneBoxExtensionEventBusEvent)event infoString:(NSString *)infoString {
    NSLog(@"TWSceneBoxSystem: event: %@, info:\n%@", event ?: @"", infoString);
}

@end
