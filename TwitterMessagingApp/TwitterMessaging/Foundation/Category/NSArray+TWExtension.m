//
//  NSArray+TWExtension.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "NSArray+TWExtension.h"

@implementation NSArray (TWExtension)

- (instancetype)tw_map:(_Nonnull id(^)(_Nonnull id))transformer {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        [mutableArray addObject:transformer(object)];
    }
    return mutableArray.copy;
}

- (instancetype)tw_filter:(BOOL (^)(id _Nonnull))filter {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        if (filter(object)) {
            [mutableArray addObject:object];
        }
    }
    return mutableArray.copy;
}

@end
