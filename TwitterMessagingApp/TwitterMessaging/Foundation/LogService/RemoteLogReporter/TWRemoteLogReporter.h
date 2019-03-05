//
//  TWRemoteLogReporter.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLogLevelObserver.h"
#import "TWDictionaryConvertible.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWRemoteLogInfo : NSObject <TWDictionaryConvertible, NSCoding>

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *data;

@end

@interface TWRemoteLogReporter : NSObject <TWLogLevelObserver>

@end

NS_ASSUME_NONNULL_END
