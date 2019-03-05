//
//  TWDictionaryConvertible.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/5.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWDictionaryConvertible <NSObject>

@required
+ (instancetype)convertFromDictionary:(NSDictionary *)dict;
+ (NSDictionary *)convertToDictionary:(id)obj;

@end

NS_ASSUME_NONNULL_END
