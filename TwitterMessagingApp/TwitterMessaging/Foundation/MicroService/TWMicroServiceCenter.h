//
//  TWMicroServiceCenter.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWMicroServiceContext.h"
#import "TWDependencyInstance.h"

@protocol TWMicroService;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT TWMicroServiceContext *GetGlobalServiceContext(void);

@interface TWMicroServiceCenter : NSObject <TWDependencyInstance>

@end

NS_ASSUME_NONNULL_END
