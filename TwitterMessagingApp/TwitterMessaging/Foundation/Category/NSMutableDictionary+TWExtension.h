//
//  NSMutableDictionary+TWExtension.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary<KeyType, ObjectType> (TWExtension)

- (void)tw_safeSetObject:(ObjectType)anObject forKey:(KeyType)aKey;

@end

NS_ASSUME_NONNULL_END
