//
//  TWRemoteLogPersistenceStrategy.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWRemoteLogInfo;
@protocol TWRemoteLogPersistenceStrategy;

NS_ASSUME_NONNULL_BEGIN

@protocol TWRemoteLogPersistenceDelegate <NSObject>

@required
- (void)persistItemFinished:(id<TWRemoteLogPersistenceStrategy>)strategy isTouchWaterLine:(BOOL)touchWaterLine;

@optional
- (void)sendDirectlyIfInEmergencyCase:(NSArray<TWRemoteLogInfo *> *)pendings completion:(void(^)(BOOL success))completion;

@end

@protocol TWRemoteLogPersistenceStrategy <NSObject>

@required
@property (nonatomic, weak) id<TWRemoteLogPersistenceDelegate> delegate;

- (void)receivedData:(TWRemoteLogInfo *)data;
- (BOOL)purgeData:(NSArray<TWRemoteLogInfo *> *)toBePurgedData;
- (NSArray<TWRemoteLogInfo *> *)persistedData;

@end

NS_ASSUME_NONNULL_END
