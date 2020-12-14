//
//  TWSceneBoxExecutor.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/21.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxExecutor.h"
#import "TWSceneBox.h"
#import "TWSceneBox+TWSceneBoxExecutor.h"

typedef NSUUID TWSceneBoxIdentifier;

@interface TWSceneBoxExecutor ()

@property (nonatomic, strong) NSMutableDictionary<TWSceneBoxIdentifier *, TWSceneBox *> *boxes;

@end

@implementation TWSceneBoxExecutor

#pragma mark - public

+ (instancetype)shared {
    static TWSceneBoxExecutor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWSceneBoxExecutor alloc] init];
    });
    return instance;
}

- (void)executeBox:(TWSceneBox *)box {
    NSParameterAssert([box isKindOfClass:TWSceneBox.class]);
    NSParameterAssert([box.boxIdentifier isKindOfClass:NSUUID.class]);
    NSParameterAssert(box.entryBlock);
    NSParameterAssert(box.exitBlock);
    NSAssert([NSThread isMainThread], @"must run on main thread");
        
    self.boxes[box.boxIdentifier] = box;
    __weak typeof(self) weakSelf = self;
    box.terminateBox = ^(TWSceneBox * _Nonnull box) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf terminateBoxProcess:box];
    };
    
    [box execute];
}

#pragma mark - private

- (void)terminateBoxProcess:(TWSceneBox *)box {
    if (box.exitBlock) {
        box.exitBlock(box.activeScene, box);
    }
    
    [self.boxes removeObjectForKey:box.boxIdentifier];
}

#pragma mark - getters

- (NSMutableDictionary<TWSceneBoxIdentifier *, TWSceneBox *> *)boxes {
    if (!_boxes) {
        _boxes = [[NSMutableDictionary alloc] init];
    }
    return _boxes;
}

@end
