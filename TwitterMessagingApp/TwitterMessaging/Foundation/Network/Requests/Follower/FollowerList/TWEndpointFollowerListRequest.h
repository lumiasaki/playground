//
//  TWEndpointFollowerListRequest.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWEndpointAPIRequest.h"

@interface TWEndpointFollowerListRequest : NSObject <TWEndpointAPIRequest>

- (instancetype)initWithParams:(NSDictionary *)params;

@end
