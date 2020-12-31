//
//  TWSceneBoxUnitTestHelperExtension.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/27.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxUnitTestHelperExtension.h"
#import "TWSceneBoxEventBus.h"
#import "TWSceneBoxSharedStateExtensionConstants.h"
#import "TWSceneBoxNavigationExtensionConstants.h"

@implementation TWSceneBoxUnitTestHelperExtension

@synthesize eventBus = _eventBus;

#pragma mark - TWSceneBoxExtension

- (TWSceneBoxExtensionType)extensionType {
    return TWSceneBoxExtensionTypeUnitTest;
}

- (NSSet<TWSceneBoxExtensionEventBusEvent> *)acceptableDispatchEventsOnEventBus {
    return [[NSSet alloc] initWithArray:@[TWSceneBoxNavigationGetScenesRequestEvent, TWSceneBoxNavigationGetScenesRequestEvent]];
}

- (void)extensionDidMount:(TWSceneBox *)sceneBox {
    if (self.extensionDidMountBlock) {
        self.extensionDidMountBlock();
    }
        
    __weak typeof(self) weakSelf = self;
    [self.eventBus watchEvent:TWSceneBoxNavigationTrackEvent next:^(NSDictionary *event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![event isKindOfClass:NSDictionary.class]) {
            return;
        }
        
        NSNumber *from = event[TWSceneBoxNavigationTrackEventFromKey];
        NSNumber *to = event[TWSceneBoxNavigationTrackEventToKey];
        
        if (strongSelf.navigationTrackBlock) {
            strongSelf.navigationTrackBlock(from, to);
        }
    }];
    
    [self.eventBus watchEvent:TWSceneBoxSharedStateChangesEvent next:^(NSDictionary *event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![event isKindOfClass:NSDictionary.class]) {
            return;
        }
        
        NSObject *key = event[TWSceneBoxExtensionEventBusEventObjectKey];
        NSObject *value = event[TWSceneBoxExtensionEventBusEventObjectValueKey];
        
        if ([key respondsToSelector:@selector(description)] && [value respondsToSelector:@selector(description)]) {
            if (strongSelf.sharedStateChangesBlock) {
                strongSelf.sharedStateChangesBlock(key, value);
            }
        }
    }];        
    
    self.getScenesBlock = ^NSArray<NSUUID *> * _Nonnull{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __block NSArray<NSUUID *> *scenes;
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [strongSelf.eventBus watchEvent:TWSceneBoxNavigationGetScenesResponseEvent next:^(NSDictionary *userInfo) {
            if (![userInfo isKindOfClass:NSDictionary.class]) {
                dispatch_semaphore_signal(semaphore);
                return;
            }
            
            scenes = userInfo[TWSceneBoxNavigationGetScenesEventObjectKey];
            dispatch_semaphore_signal(semaphore);
        }];
        
        [strongSelf.eventBus dispatch:TWSceneBoxNavigationGetScenesRequestEvent userInfo:@{}];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        return scenes ?: @[];
    };
}

#pragma mark - TWSceneBoxLifeCycle

- (void)sceneBoxWillTerminate {
    if (self.sceneBoxWillTerminateBlock) {
        self.sceneBoxWillTerminateBlock();
    }
}

@end
