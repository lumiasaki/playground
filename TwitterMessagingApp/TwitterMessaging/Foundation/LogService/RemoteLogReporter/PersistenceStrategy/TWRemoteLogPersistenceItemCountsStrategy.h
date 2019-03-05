//
//  TWRemoteLogPersistenceItemCountsStrategy.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWRemoteLogPersistenceStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWRemoteLogPersistenceItemCountsStrategyBuilder : NSObject

@property (nonatomic, weak) id<TWRemoteLogPersistenceDelegate> delegate;
@property (nonatomic, assign) NSUInteger persistenceMaxCount;
@property (nonatomic, assign) NSUInteger pendingMaxCount;

@end

@interface TWRemoteLogPersistenceItemCountsStrategy : NSObject <TWRemoteLogPersistenceStrategy>

- (instancetype)initWithBuilder:(void(^)(TWRemoteLogPersistenceItemCountsStrategyBuilder *builder))block;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("Use `initWithBuilder:` instead")));

@end

NS_ASSUME_NONNULL_END
