//
//  TWLogService.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2019/1/9.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWLogService.h"
#import "TWLogLevelObserver.h"

@interface TWLogService ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<id<TWLogLevelObserver>> *> *observers;
@property (nonatomic, assign) BOOL consumersRegisterLocked;

@end

@implementation TWLogService {
    dispatch_queue_t _workQueue;
}

+ (instancetype)shared {
    static TWLogService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWLogService alloc] init];
        instance->_workQueue = dispatch_queue_create("com.faketwitter.twtwitterdm.logservice", DISPATCH_QUEUE_CONCURRENT);
        
        instance.observers = [[NSMutableDictionary alloc] init];
        instance.observers[@(TWLogLevelDebug)] = [[NSMutableArray alloc] init];
        instance.observers[@(TWLogLevelInfo)] = [[NSMutableArray alloc] init];
        instance.observers[@(TWLogLevelWarn)] = [[NSMutableArray alloc] init];
        instance.observers[@(TWLogLevelError)] = [[NSMutableArray alloc] init];
        instance.observers[@(TWLogLevelFatal)] = [[NSMutableArray alloc] init];
    });
    return instance;
}

- (void)registerObserver:(id<TWLogLevelObserver>)observer onLevel:(TWLogLevel)level {
    if (_consumersRegisterLocked) {
        return;
    }
    
    if (![observer conformsToProtocol:@protocol(TWLogLevelObserver)]) {
        return;
    }
    
    NSDictionary<NSNumber *, NSArray<id<TWLogLevelObserver>> *> * observers = [self observersOnLevelOption:TWLogLevelAll];
    
    if ([observers isKindOfClass:NSDictionary.class]) {
        [observers enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSArray<id<TWLogLevelObserver>> * _Nonnull obj, BOOL * _Nonnull stop) {
            if ((key.integerValue & level) && [obj isKindOfClass:NSMutableArray.class]) {
                @synchronized (obj) {
                    [(NSMutableArray *)obj addObject:observer];
                }
            }
        }];
    }
}

- (void)setUpDone {
    @synchronized (self.observers) {
        self.consumersRegisterLocked = YES;
    }
}

- (void)receivedInformation:(TWLogInformation *)information {
    @synchronized (self.observers) {
        if (!information || !self.consumersRegisterLocked) {
            return;
        }
        
        dispatch_async(_workQueue, ^{
            NSDictionary<NSNumber *, NSArray<id<TWLogLevelObserver>> *> *observers = [self observersOnLevelOption:information.logLevel];
            
            if (![observers isKindOfClass:NSDictionary.class]) {
                return;
            }
            
            [observers enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSArray<id<TWLogLevelObserver>> * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:NSArray.class]) {
                    [obj enumerateObjectsUsingBlock:^(id<TWLogLevelObserver>  _Nonnull observer, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([observer respondsToSelector:@selector(consumeObservedInformation:)]) {
                            [observer consumeObservedInformation:information.copy];
                        }
                    }];
                }
            }];
        });
    }
}

#pragma mark - private

- (NSArray<id<TWLogLevelObserver>> *)observersOnDebug {
    return self.observers[@(TWLogLevelDebug)];
}

- (NSArray<id<TWLogLevelObserver>> *)observersOnInfo {
    return self.observers[@(TWLogLevelInfo)];
}

- (NSArray<id<TWLogLevelObserver>> *)observersOnWarn {
    return self.observers[@(TWLogLevelWarn)];
}

- (NSArray<id<TWLogLevelObserver>> *)observersOnError {
    return self.observers[@(TWLogLevelError)];
}

- (NSArray<id<TWLogLevelObserver>> *)observersOnFatal {
    return self.observers[@(TWLogLevelFatal)];
}

#pragma mark - getter

- (NSDictionary<NSNumber *, NSArray<id<TWLogLevelObserver>> *> *)observersOnLevelOption:(TWLogLevel)level {
    NSMutableDictionary<NSNumber *, NSArray<id<TWLogLevelObserver>> *> *result = [[NSMutableDictionary alloc] init];
    
    if (level & TWLogLevelDebug) {
        result[@(TWLogLevelDebug)] = [self observersOnDebug];
    }
    
    if (level & TWLogLevelInfo) {
        result[@(TWLogLevelInfo)] = [self observersOnInfo];
    }
    
    if (level & TWLogLevelWarn) {
        result[@(TWLogLevelWarn)] = [self observersOnWarn];
    }
    
    if (level & TWLogLevelError) {
        result[@(TWLogLevelError)] = [self observersOnError];
    }
    
    if (level & TWLogLevelFatal) {
        result[@(TWLogLevelFatal)] = [self observersOnFatal];
    }
    
    return result.copy;
}

@end

@implementation TWLogInformation

- (instancetype)copyWithZone:(NSZone *)zone {
    TWLogInformation *instance = [[self.class allocWithZone:zone] init];
    
    instance.message = self.message;
    instance.logLevel = self.logLevel;
    instance.extraInfo = self.extraInfo;
    
    return instance;
}

@end
