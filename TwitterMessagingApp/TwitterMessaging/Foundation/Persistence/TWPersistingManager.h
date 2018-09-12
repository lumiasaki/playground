//
//  TWPersistingModule.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWPersisting.h"

@interface TWPersistingManager : NSObject <TWPersisting>

+ (instancetype)sharedManager;

@end
