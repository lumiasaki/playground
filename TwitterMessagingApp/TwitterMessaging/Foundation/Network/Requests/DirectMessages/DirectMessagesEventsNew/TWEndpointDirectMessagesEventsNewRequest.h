//
//  TWEndpointDirectMessagesEventsNewRequest.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWEndpointAPIRequest.h"

// although the messaging is dummy, I still make this class for the possibility of implementing a real messaging part in the future.
@interface TWEndpointDirectMessagesEventsNewRequest : NSObject <TWEndpointAPIRequest>

- (instancetype)initWithParams:(NSDictionary *)params;

@end
