//
//  TWBinaryTuple.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/21.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWBinaryTuple<ObjectType1, ObjectType2> : NSObject

@property (nonatomic, strong, nullable) ObjectType1 $0;
@property (nonatomic, strong, nullable) ObjectType2 $1;

@end

NS_ASSUME_NONNULL_END
