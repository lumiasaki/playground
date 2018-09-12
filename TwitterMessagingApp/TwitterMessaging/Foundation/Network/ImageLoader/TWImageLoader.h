//
//  TWImageLoader.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2018/8/8.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// a really simple ImageLoader, in real case, using SDWebImage or other image loading framework is a much better choice
@interface TWImageLoader : NSObject

+ (void)downloadImageWithUrl:(NSString *)url completion:(void(^)(NSString *, UIImage *))completion;

@end
