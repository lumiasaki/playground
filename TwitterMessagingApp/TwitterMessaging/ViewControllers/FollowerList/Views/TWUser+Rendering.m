//
//  TWUser+Rendering.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2018/8/8.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWUser+Rendering.h"

@implementation TWUser (Rendering)

- (NSAttributedString *)nameAttributeString {
    NSString *nameString = [NSString stringWithFormat:@"%@ %@", self.screenName, self.name];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:nameString];
    
    [attributedString addAttributes:@{
                                      NSForegroundColorAttributeName : UIColor.whiteColor,
                                      NSFontAttributeName : [UIFont boldSystemFontOfSize:17],
                                      } range:NSMakeRange(0, self.screenName.length)];
    
    [attributedString addAttributes:@{
                                      NSForegroundColorAttributeName : [UIColor colorWithRed:140 green:140 blue:140 alpha:1],
                                      NSFontAttributeName : [UIFont systemFontOfSize:12]
                                      } range:NSMakeRange(self.screenName.length + 1, self.name.length)];
    
    return attributedString.copy;
}

@end
