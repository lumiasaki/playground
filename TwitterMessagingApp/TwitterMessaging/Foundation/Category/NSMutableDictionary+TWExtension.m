//
//  NSMutableDictionary+TWExtension.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "NSMutableDictionary+TWExtension.h"

@implementation NSMutableDictionary (TWExtension)

- (void)tw_safeSetObject:(id)anObject forKey:(id)aKey {
    if (!anObject || !aKey) {
        return;
    }
    
    [self setObject:anObject forKey:aKey];
}

@end
