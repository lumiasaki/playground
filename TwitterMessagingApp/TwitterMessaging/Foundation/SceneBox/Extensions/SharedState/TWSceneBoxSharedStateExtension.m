//
//  TWSceneBoxSharedStateExtension.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxSharedStateExtension.h"
#import "TWSceneBoxSharedStateExtensionConstants.h"
#import "TWSceneBoxEventBus.h"

@interface TWSceneBoxSharedStateExtension ()

@property (nonatomic, strong) NSMutableDictionary *state;

@end

@implementation TWSceneBoxSharedStateExtension

@synthesize eventBus = _eventBus;

#pragma mark - TWSceneBoxExtension

- (TWSceneBoxExtensionType)extensionType {
    return TWSceneBoxExtensionTypeSharedState;
}

- (NSSet<TWSceneBoxExtensionEventBusEvent> *)acceptableDispatchEventsOnEventBus {
    return [NSSet setWithArray:@[TWSceneBoxSharedStateChangesEvent]];
}

#pragma mark - public

- (nullable id)querySharedStateByKey:(nonnull id)key {
    return [self.state objectForKey:key];
}

- (void)setSharedState:(nonnull id)state onKey:(nonnull id)key {
    if (!state || ![key conformsToProtocol:@protocol(NSCopying)]) {
        return;
    }
    
    @synchronized (self.state) {
        [self.state setObject:state forKey:key];
        
        [self.eventBus dispatch:TWSceneBoxSharedStateChangesEvent userInfo:@{
            TWSceneBoxExtensionEventBusEventObjectKey : key,
            TWSceneBoxExtensionEventBusEventObjectValueKey : state
        }];
    }
}

#pragma mark - getter

- (NSMutableDictionary *)state {
    if (!_state) {
        _state = [[NSMutableDictionary alloc] init];
    }
    return _state;
}

@end
