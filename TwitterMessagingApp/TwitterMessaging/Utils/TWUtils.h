//
//  TWUtils.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWEndpointAPIRequest.h"

@interface TWUtils : NSObject

// check if a endpoint request is valid
+ (BOOL)validateEndpointRequest:(id<TWEndpointAPIRequest>)request;

// check if a string is nil or empty
+ (BOOL)stringIsEmpty:(NSString *)string;

// encode a string into url encoded string
+ (NSString *)encodeURL:(NSString *)urlString;

// transfrom a NSDate to a NSString, by formatting string
+ (NSString *)formattedDateString:(NSDate *)date format:(NSString *)format;

// transfrom a NSString to a NSDate, by formatting string
+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

+ (NSArray<Class> *)getAllClasses;

@end
