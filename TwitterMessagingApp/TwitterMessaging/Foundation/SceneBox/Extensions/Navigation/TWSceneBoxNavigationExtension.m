//
//  TWSceneBoxNavigationExtension.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/25.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxNavigationExtension.h"
#import "TWSceneBoxNavigationExtensionConstants.h"
#import "TWSceneBoxEventBus.h"
#import "TWSceneBox.h"

static const NSInteger TWSceneBoxNavigationExtensionEntryState = NSIntegerMin;
static const NSInteger TWSceneBoxNavigationExtensionTerminateState = NSIntegerMax;

@interface TWSceneBoxNavigationExtension () <UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray<NSNumber *> *stateTrace;
@property (nonatomic, strong, nullable) id<UINavigationControllerDelegate> previousNavigationControllerDelegate;

@end

@implementation TWSceneBoxNavigationExtension

@synthesize eventBus = _eventBus;
@synthesize terminateBox = _terminateBox;
@synthesize getScenes = _getScenes;
@synthesize markSceneAsActive = _markSceneAsActive;
@synthesize navigateToScene = _navigateToScene;
@synthesize stateSceneIdentifierTable = _stateSceneIdentifierTable;

#pragma mark - TWSceneBoxExtension

- (TWSceneBoxExtensionType)extensionType {
    return TWSceneBoxExtensionTypeNavigation;
}

- (NSSet<TWSceneBoxExtensionEventBusEvent> *)acceptableDispatchEventsOnEventBus {
    return [NSSet setWithArray:@[TWSceneBoxNavigationTrackEvent, TWSceneBoxNavigationGetScenesResponseEvent]];
}

- (void)extensionDidMount:(TWSceneBox *)sceneBox {
    assert([self.stateSceneIdentifierTable isKindOfClass:NSDictionary.class]);
    
    self.previousNavigationControllerDelegate = sceneBox.configuration.navigationController.delegate;
    sceneBox.configuration.navigationController.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [self.eventBus watchEvent:TWSceneBoxNavigationGetScenesRequestEvent next:^(NSDictionary *userInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.eventBus dispatch:TWSceneBoxNavigationGetScenesResponseEvent userInfo:@{
            TWSceneBoxNavigationGetScenesEventObjectKey : strongSelf.getScenes() ?: @[]
        }];
    }];
}

#pragma mark - TWSceneBoxNavigationExtension

+ (NSInteger)entryState {
    return TWSceneBoxNavigationExtensionEntryState;
}

+ (NSInteger)terminationState {
    return TWSceneBoxNavigationExtensionTerminateState;
}

- (void)transitToState:(nonnull NSNumber *)state {
    NSAssert([NSThread isMainThread], @"must run on main thread");
    
    if (self.stateTrace.count > 0) {
        [self.eventBus dispatch:TWSceneBoxNavigationTrackEvent userInfo:@{
            TWSceneBoxNavigationTrackEventFromKey : @(self.currentState.integerValue),
            TWSceneBoxNavigationTrackEventToKey : @(state.integerValue)
        }];
    }
    
    if ([state isEqual:@(self.class.entryState)] && self.stateTrace.count == 0) {
        [self.stateTrace addObject:@(self.class.entryState)];
        return;
    }
    
    NSInteger indexOfStateInTrace = [self.stateTrace indexOfObject:state];
    if (indexOfStateInTrace != NSNotFound) {
        NSRange range = NSMakeRange(MIN(indexOfStateInTrace + 1, self.stateTrace.count - 1), self.stateTrace.count - indexOfStateInTrace - 1);
        
        [self.stateTrace removeObjectsInRange:range];
    } else {
        [self.stateTrace addObject:state];
    }
    
    if ([state isEqual:@(self.class.terminationState)]) {
        NSAssert([self.currentState isKindOfClass:NSNumber.class], @"currentState is nil");
                        
        self.terminateBox();
        return;
    }
    
    NSUUID *identifier = [self.stateSceneIdentifierTable objectForKey:state];
    if (identifier) {
        self.navigateToScene(identifier);
        self.markSceneAsActive(identifier);
    }
}

- (nullable NSNumber *)currentState {
    return self.stateTrace.lastObject;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController<TWSceneBoxScene> *)viewController animated:(BOOL)animated {
    if ([viewController conformsToProtocol:@protocol(TWSceneBoxScene)]) {
        NSUUID *identifier = viewController.sceneIdentifier;
        if (identifier) {
            self.navigateToScene(identifier);
            self.markSceneAsActive(identifier);
        }
    }
    
    if ([self.previousNavigationControllerDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.previousNavigationControllerDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

#pragma mark - getter

- (NSMutableArray<NSNumber *> *)stateTrace {
    if (!_stateTrace) {
        _stateTrace = [[NSMutableArray alloc] init];
    }
    return _stateTrace;
}

@end
