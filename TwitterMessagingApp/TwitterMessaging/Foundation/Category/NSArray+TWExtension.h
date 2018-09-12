//
//  NSArray+TWExtension.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TWExtension)

- (instancetype)tw_map:(_Nonnull id(^)(_Nonnull id))transformer;
- (instancetype)tw_filter:(BOOL(^)(_Nonnull id))filter;

@end
