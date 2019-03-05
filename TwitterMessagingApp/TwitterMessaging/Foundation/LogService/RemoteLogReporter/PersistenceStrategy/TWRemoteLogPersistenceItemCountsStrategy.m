//
//  TWRemoteLogPersistenceItemCountsStrategy.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWRemoteLogPersistenceItemCountsStrategy.h"
#import "TWRemoteLogReporter.h"
#import "TWUtils.h"
#import "TWLogService.h"
#import "TWRemoteLogInfo+TWPrivate.h"
#import <UIKit/UIKit.h>
#import "NSArray+TWExtension.h"

static NSString *const PERSISTENCE_FILE_PREFIX = @"TW_PENDING_ERROR_LOG_FILE";
static const NSUInteger DEFAULT_PENDING_IN_MEMORY_MAX_COUNT = 5;
static const NSUInteger DEFAULT_PERSITENCE_IN_DISK_MAX_COUNT = 3;

@implementation TWRemoteLogPersistenceItemCountsStrategyBuilder @end

@interface TWRemoteLogPersistenceItemCountsStrategy ()

@property (nonatomic, assign) dispatch_queue_t workQueue;
@property (nonatomic, strong) NSMutableArray<TWRemoteLogInfo *> *pendingRemoteLogInfos;

// configuration properties
@property (nonatomic, assign) NSUInteger persistenceMaxCount;
@property (nonatomic, assign) NSUInteger pendingMaxCount;

@end

@implementation TWRemoteLogPersistenceItemCountsStrategy

@synthesize delegate = _delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithBuilder:(void(^)(TWRemoteLogPersistenceItemCountsStrategyBuilder * _Nonnull))block {
    if (self = [super init]) {
        TWRemoteLogPersistenceItemCountsStrategyBuilder *builder = [[TWRemoteLogPersistenceItemCountsStrategyBuilder alloc] init];
        
        if (block) {
            block(builder);
            
            _delegate = builder.delegate;
            _persistenceMaxCount = builder.persistenceMaxCount == 0 ? DEFAULT_PERSITENCE_IN_DISK_MAX_COUNT : builder.persistenceMaxCount;
            _pendingMaxCount = builder.pendingMaxCount == 0 ? DEFAULT_PENDING_IN_MEMORY_MAX_COUNT : builder.pendingMaxCount;
        }
        
        _pendingRemoteLogInfos = [[NSMutableArray alloc] init];
        
        [self registerNotifications];
        
        // when init, execute once pre-start check and invoke once `isTouchWaterLine` with YES if needed
        [self executePreStartActivities];
    }
    
    return self;
}

#pragma mark - TWRemoteLogPersistenceStrategy

- (void)receivedData:(nonnull TWRemoteLogInfo *)data {
    TWExecuteTaskOnWorkQueue(^{
        if (![data isKindOfClass:TWRemoteLogInfo.class]) {
            return;
        }
        
        [self addPendingData:data];
    }, NO);
}

- (NSArray<TWRemoteLogInfo *> *)persistedData {
    __block NSArray<TWRemoteLogInfo *> *result = @[];
    
    TWExecuteTaskOnWorkQueue(^{
        result = convertPersistedFileDirsToDictionary(searchAllPersistedFiles());
    }, YES);
    
    return result;
}

- (BOOL)purgeData:(nonnull NSArray<TWRemoteLogInfo *> *)toBePurgedData {
    NSMutableSet<NSNumber *> *purgeResults = [[NSMutableSet alloc] init];
    
    TWExecuteTaskOnWorkQueue(^{
        NSMutableSet<NSString *> *possibleFilePaths = [[NSMutableSet alloc] init];
        
        [toBePurgedData enumerateObjectsUsingBlock:^(TWRemoteLogInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:TWRemoteLogInfo.class] && ![TWUtils stringIsEmpty:obj.tw_associatedFileName]) {
                [possibleFilePaths addObject:obj.tw_associatedFileName];
            }
        }];
        
        if (possibleFilePaths.count != 0) {
            [possibleFilePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:NSString.class]) {
                    BOOL removeResult = [self removeFileSync:obj];
                    [purgeResults addObject:@(removeResult)];
                }
            }];
        }
    }, YES);
    
    return purgeResults.count == 1 && [purgeResults.anyObject isEqualToNumber:@(YES)];
}

#pragma mark - private

- (void)registerNotifications {
    // when enter background or terminate, force save pending log infos into file
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterBackgroundOrTerminate:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterBackgroundOrTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    // when enter foreground, force invoke once `persistItemFinished:isTouchWaterLine:` with YES, to send to remote server
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)addPendingData:(TWRemoteLogInfo *)data {
    NSAssert(TWIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    if ([data isKindOfClass:TWRemoteLogInfo.class]) {
        [self.pendingRemoteLogInfos addObject:data];
        
        [self synclySaveToFileIfNeeded];
    }
}

- (void)synclySaveToFileIfNeeded {
    NSAssert(TWIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    NSArray<TWRemoteLogInfo *> *scopedArray = [[NSArray alloc] initWithArray:self.pendingRemoteLogInfos];
    
    if (scopedArray.count > self.pendingMaxCount) {
        static const NSInteger SAVE_FILE_RETRY_TIME = 3;
        
        BOOL saveSuccessfully = NO;
        for (NSInteger i = 0; i < SAVE_FILE_RETRY_TIME; i++) {
            if ([self writeToFileSync:self.distributeAnAvailableFilePath data:scopedArray]) {
                if ([self.delegate respondsToSelector:@selector(persistItemFinished:isTouchWaterLine:)]) {
                    [self.delegate persistItemFinished:self isTouchWaterLine:self.checkIfReachWaterLine];
                }
                
                saveSuccessfully = YES;
                [self.pendingRemoteLogInfos removeObjectsInArray:scopedArray];
                
                break;
            }
        }
        
        if (!saveSuccessfully && [self.delegate respondsToSelector:@selector(sendDirectlyIfInEmergencyCase:completion:)]) {
            [self.delegate sendDirectlyIfInEmergencyCase:scopedArray completion:^(BOOL success) {
                TWExecuteTaskOnWorkQueue(^{
                    if (success) {
                        // purge inside the strategy class, because I don't want caller to care about how to handle with failure case of `writeToFile:data:`
                        // other cases, we should always delegate the result to delegate
                        [self purgeData:scopedArray];
                        
                        [self.pendingRemoteLogInfos removeObjectsInArray:scopedArray];
                    }
                    
                    // if success == false
                    // if failed, do not execute purging, just keep them in the pending data, then invoke next time `synclySaveToFileIfNeeded` to try to save them into files, noted, this file is larger than normal one
                }, NO);
            }];
        }
    }
}

- (BOOL)writeToFileSync:(NSString *)path data:(NSArray<id<NSCoding>> *)pendings {
    NSAssert(TWIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    if ([TWUtils stringIsEmpty:path] || ![pendings isKindOfClass:NSArray.class]) {
        return NO;
    }
    
    // for purging purpose
    for (TWRemoteLogInfo *logInfo in pendings) {
        if ([logInfo isKindOfClass:TWRemoteLogInfo.class]) {
            logInfo.tw_associatedFileName = path;
        }
    }
    
    BOOL result = [NSKeyedArchiver archiveRootObject:pendings toFile:path];
    
    if (!result) {
        for (TWRemoteLogInfo *logInfo in pendings) {
            if ([logInfo isKindOfClass:TWRemoteLogInfo.class]) {
                logInfo.tw_associatedFileName = nil;
            }
        }
    }
    
    return result;
}

- (BOOL)removeFileSync:(NSString *)path {
    NSAssert(TWIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    if ([TWUtils stringIsEmpty:path]) {
        return NO;
    }
    
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        NSError *error;
        [NSFileManager.defaultManager removeItemAtPath:path error:&error];
        
        return error == nil;
    }
    
    return YES;
}

- (NSString *)distributeAnAvailableFilePath {
    NSAssert(TWIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    static NSUInteger uniqueID = 0;
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    BOOL pathIsAvailable = NO;
    NSString *result = nil;
    
    // use case for restart app, unique id start from 0 again, but there was a file already existed.
    do {
        NSString *fileName = [NSString stringWithFormat:@"/%@%lu.dat", PERSISTENCE_FILE_PREFIX, (unsigned long)uniqueID++];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheDir stringByAppendingString:fileName]]) {
            pathIsAvailable = YES;
            
            result = [cacheDir stringByAppendingString:fileName];
        }
    } while (!pathIsAvailable);
    
    return result;
}

- (BOOL)checkIfReachWaterLine {
    NSAssert(TWIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    return self.persistedData.count > self.persistenceMaxCount;
}

- (void)executePreStartActivities {
    TWExecuteTaskOnWorkQueue(^{
        if (self.persistedData.count > 0 && [self.delegate respondsToSelector:@selector(persistItemFinished:isTouchWaterLine:)]) {
            // here, use YES for `isTouchWaterLine` field forcely, to invoke an upload to remote server
            [self.delegate persistItemFinished:self isTouchWaterLine:YES];
        }
    }, NO);
}

#pragma mark - notification responder

- (void)applicationWillEnterBackgroundOrTerminate:(NSNotification *)notification {
    TWExecuteTaskOnWorkQueue(^{
        if (self.pendingRemoteLogInfos.count > 0) {
            [self writeToFileSync:self.distributeAnAvailableFilePath data:self.pendingRemoteLogInfos];
        }
    }, NO);
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // is same as `executePreStartActivities`, check if crash report existed, and check if exist persistedData, then forcely invoke `isTouchWaterLine` with YES
    [self executePreStartActivities];
}

#pragma mark - getter

static dispatch_queue_t TWGetRemoteLogPersistWorkQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.faketwitter.twtwitterdm.logger.persist.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

#pragma mark - utils

static BOOL TWIsRemoteLogPersistWorkQueue() {
    static void *queueKey = &queueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(TWGetRemoteLogPersistWorkQueue(), queueKey, queueKey, NULL);
    });
    
    return dispatch_get_specific(queueKey) == queueKey;
}

static void TWExecuteTaskOnWorkQueue(dispatch_block_t task, BOOL sync) {
    if (TWIsRemoteLogPersistWorkQueue()) {
        if (sync) {
            task();
        } else {
            dispatch_async(TWGetRemoteLogPersistWorkQueue(), task);
        }
    } else if (sync) {
        dispatch_sync(TWGetRemoteLogPersistWorkQueue(), task);
    } else {
        dispatch_async(TWGetRemoteLogPersistWorkQueue(), task);
    }
}

static NSArray<NSString *> *searchAllPersistedFiles() {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in allFilesAtPath(directory)) {
        if ([fileName containsString:PERSISTENCE_FILE_PREFIX]) {
            [result addObject:fileName];
        }
    }
    
    return result.copy;
}

static NSArray<NSString *> *allFilesAtPath(NSString *path) {
    NSMutableArray *pathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:path error:nil]) {
        BOOL flag = YES;
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                [pathArray addObjectsFromArray:allFilesAtPath(fullPath)];
            }
        }
    }
    
    return pathArray.copy;
}

static NSArray<TWRemoteLogInfo *> *convertPersistedFileDirsToDictionary(NSArray<NSString *> *dirs) {
    NSMutableArray<NSArray<TWRemoteLogInfo *> *> *result = [[NSMutableArray alloc] init];
    
    for (NSString *fullPath in dirs) {
        NSArray<TWRemoteLogInfo *> *logInfos = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        if (logInfos) {
            [result addObject:logInfos];
        }
    }
    
    return [result tw_flatMap:^id _Nonnull(id _Nonnull obj) {
        return obj;
    }].copy;
}

@end
