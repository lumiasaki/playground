//
//  UIImageView+DownLoadImage.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/8.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "UIImageView+DownLoadImage.h"
#import "TWImageLoader.h"
#import <objc/runtime.h>

@implementation UIImageView (DownLoadImage)

- (void)tw_setImageUrl:(NSString *)imageUrl {
    [self tw_setImageUrlIdentifier:imageUrl];
    [TWImageLoader downloadImageWithUrl:imageUrl completion:^(NSString *url, UIImage *image) {        
        if ([url isEqualToString:[self tw_imageUrlIdentifier]]) {
            self.image = image;
        } else {
            self.image = nil;
        }
    }];
}

- (void)tw_setImageUrlIdentifier:(NSString *)url {
    objc_setAssociatedObject(self, @selector(tw_imageUrlIdentifier), url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)tw_imageUrlIdentifier {
    return objc_getAssociatedObject(self, _cmd);
}

@end
