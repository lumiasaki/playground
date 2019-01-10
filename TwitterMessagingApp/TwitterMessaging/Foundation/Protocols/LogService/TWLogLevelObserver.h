//
//  TWLogLevelObserver.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/1/9.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWLogInformation;

NS_ASSUME_NONNULL_BEGIN

@protocol TWLogLevelObserver <NSObject>

@required
- (void)consumeObservedInformation:(TWLogInformation *)information;

@end

NS_ASSUME_NONNULL_END
