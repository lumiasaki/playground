//
//  TWRemoteLogReporter.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWRemoteLogReporter.h"
#import <UIKit/UIKit.h>
#import "TWLogService.h"
#import "TWRemoteLogPersistenceStrategy.h"
#import "TWRemoteLogPersistenceItemCountsStrategy.h"
#import "NSMutableDictionary+TWExtension.h"
#import "NSArray+TWExtension.h"
#import "TWRemoteLogInfo+TWPrivate.h"
#import "TWEndpointAPIRequest.h"

static const NSString *const REMOTE_LOG_BASEURL = @"";
static const NSString *const REMOTE_LOG_ENDPOINT = @"";

@implementation TWRemoteLogInfo

#pragma mark - TWDictionaryConvertible

+ (instancetype)convertFromDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    TWRemoteLogInfo *result = [[TWRemoteLogInfo alloc] init];
    
    result.data = dict[@"data"];
    result.tw_associatedFileName = dict[@"associatedFileName"];
    
    return result;
}

+ (NSDictionary *)convertToDictionary:(TWRemoteLogInfo *)obj {
    if (![obj isKindOfClass:self]) {
        return nil;
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result tw_safeSetObject:obj.data forKey:@"data"];
    [result tw_safeSetObject:obj.tw_associatedFileName forKey:@"associatedFileName"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _data = [aDecoder decodeObjectForKey:@"data"];
        self.tw_associatedFileName = [aDecoder decodeObjectForKey:@"associatedFileName"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeObject:self.tw_associatedFileName forKey:@"associatedFileName"];
}

@end

@interface TWRemoteLogParams : NSObject <TWEndpointAPIRequest>

@property (nonatomic, strong) NSArray<NSDictionary *> *logs;

@end

@implementation TWRemoteLogParams

- (NSString *)endpoint {
    return [NSString stringWithFormat:@"%@%@", REMOTE_LOG_BASEURL, REMOTE_LOG_ENDPOINT];
}

- (NSString *)httpMethod {
    return @"post";
}

- (NSDictionary *)params {
    return @{ @"logs": self.logs ?: @[]};
}

- (NSDictionary *)additionalHeaders {
    return @{};
}

- (TWNetworkDataSerializerType)serializerType {
    return TWNetworkDataSerializerJSONType;
}

- (TWNetworkDataSerializerType)deserializerType {
    return TWNetworkDataSerializerJSONType;
}

@end

@interface TWRemoteLogReporter () <TWRemoteLogPersistenceDelegate>

@property (nonatomic, strong) id<TWRemoteLogPersistenceStrategy> persistenceStrategy;

@end

@implementation TWRemoteLogReporter

- (instancetype)init {
    if (self = [super init]) {
        // choose any type you like, here use persistence item count strategy
        _persistenceStrategy = [[TWRemoteLogPersistenceItemCountsStrategy alloc] initWithBuilder:^(TWRemoteLogPersistenceItemCountsStrategyBuilder * _Nonnull builder) {
            
            builder.delegate = self;
        }];
    }
    
    return self;
}

#pragma mark - TWRemoteLogPersistenceDelegate

- (void)persistItemFinished:(id<TWRemoteLogPersistenceStrategy>)strategy isTouchWaterLine:(BOOL)touchWaterLine {
    if (touchWaterLine) {
        // 1. retrieve persistence data from strategy
        NSArray<TWRemoteLogInfo *> *persistedData = strategy.persistedData;
        
        // 2. send them
        if ([persistedData isKindOfClass:NSArray.class] && persistedData.count > 0) {
            [self sendToRemote:[self remoteLogParamsFrom:persistedData] completion:^(BOOL success) {
                
                // 3. purge them from strategy if successfully send to remote server, or else, wait for next time `persistItemFinished:isTouchWaterLine:`
                if (success) {
                    [strategy purgeData:persistedData];
                }
            }];
        }
    }
}

- (void)sendDirectlyIfInEmergencyCase:(NSArray<TWRemoteLogInfo *> *)pendings completion:(void (^)(__unused BOOL success))completion {
    [self sendToRemote:[self remoteLogParamsFrom:pendings] completion:nil];
}

#pragma mark - TWLogLevelObserver

- (void)consumeObservedInformation:(TWLogInformation *)information {
    if (![information isKindOfClass:TWLogInformation.class]) {
        return;
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{@"__extraInfo" : information.extraInfo ?: @{}}];
    [dictionary tw_safeSetObject:information.message forKey:@"__message"];
    [dictionary tw_safeSetObject:information.logLevelLiteral forKey:@"__logLevel"];
    [dictionary tw_safeSetObject:[NSString stringWithFormat:@"%f", information.timestamp] forKey:@"__timestamp"];
    
    [self.persistenceStrategy receivedData:({
        TWRemoteLogInfo *params = [[TWRemoteLogInfo alloc] init];
        params.data = dictionary.copy;
        
        params;
    })];
}

#pragma mark - private

- (void)sendToRemote:(TWRemoteLogParams *)params completion:(void(^)(BOOL success))completion {
    if ([params isKindOfClass:TWRemoteLogParams.class] || ![params.logs isKindOfClass:NSArray.class] || params.logs.count <= 0) {
        return;
    }
    
    // send to remote server use params via TWEndpointAPIManager
}

- (void(^)(NSURLResponse *, id, NSError *))requestCompletionThen:(void(^)(BOOL success))completion {
    return ^(NSURLResponse *urlResponse, id decodedObject, NSError *error) {
        if (completion) {
            // TODO: add any additional condition
            completion(error || (((NSHTTPURLResponse *)urlResponse).statusCode < 200 || ((NSHTTPURLResponse *)urlResponse).statusCode >= 300));
        }
    };
}

- (TWRemoteLogParams *)remoteLogParamsFrom:(NSArray<TWRemoteLogInfo *> *)logs {
    TWRemoteLogParams *params = [[TWRemoteLogParams alloc] init];
    
    params.logs = (NSArray<NSDictionary *> *)[logs tw_map:^NSDictionary * _Nonnull(TWRemoteLogInfo * _Nonnull obj) {
        NSAssert([obj isKindOfClass:TWRemoteLogInfo.class], @"obj in here should always be TWRemoteLogInfo.class");
        if (![obj isKindOfClass:TWRemoteLogInfo.class]) {
            return @{};
        }
        return [TWRemoteLogInfo convertToDictionary:obj];
    }];
    
    return params;
}

@end
