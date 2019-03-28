//
//  TWUniversalEvent.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWUniversalEvent : NSObject

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSDictionary<NSString *, id> *content;
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
