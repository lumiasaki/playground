//
//  TWEndpointAPIManager+FollowerListRequest.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager+FollowerListRequest.h"
#import "TWEndpointFollowerListRequest.h"
#import "TWUtils.h"

@implementation TWEndpointAPIManager (FollowerListRequest)

+ (TWEndpointRequestOperation *)fetchFollowerList:(NSDictionary *)params completion:(TWEndpointResponseBlock)completion {
    // sorry for this, I have no valid keys for requesting real data, so just return mocks simply
    
//    return [self startEndpointRequest:[[TWEndpointFollowerListRequest alloc] initWithParams:params] completion:completion];    
    if (completion) {
        completion(nil, self.mockFollowersResponse, nil);
    }
    return nil;
}

#pragma mark - private

// return dummy followers
+ (NSDictionary *)mockFollowersResponse {
    return @{@"users":@[@{
                            @"id_str": @"1",
                            @"name": @"@__saki",
                            @"screen_name": @"saki、",
                            @"create_at": [TWUtils formattedDateString:NSDate.date format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/930839642886176768/WdaEkpgb_400x400.jpg"
                            }, @{
                            @"id_str": @"2",
                            @"name": @"@clattner_llvm",
                            @"screen_name": @"Chris Lattner",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:20] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/948421391690252288/e2Ti9PMU_400x400.jpg"
                            }, @{
                            @"id_str": @"3",
                            @"name": @"@tim_cook",
                            @"screen_name": @"Tim Cook",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:30] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/378800000483764274/ebce94fb34c055f3dc238627a576d251_400x400.jpeg"
                            }, @{
                            @"id_str": @"4",
                            @"name": @"@mattt",
                            @"screen_name": @"Mattt",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:40] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/969321564050112513/fbdJZmEh_400x400.jpg"
                            }, @{
                            @"id_str": @"5",
                            @"name": @"@reactnative",
                            @"screen_name": @"React Native",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:50] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/763061332702736385/KoK6gHzp_400x400.jpg"
                            }, @{
                            @"id_str": @"6",
                            @"name": @"@katorena_710",
                            @"screen_name": @"加藤玲奈",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:60] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/974839773230596096/w0Rl52fy_400x400.jpg"
                            }, @{
                            @"id_str": @"7",
                            @"name": @"@dan_abramov",
                            @"screen_name": @"Dan Abramov",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:70] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/906557353549598720/oapgW_Fp_400x400.jpg"
                            }, @{
                            @"id_str": @"8",
                            @"name": @"@nogizaka46",
                            @"screen_name": @"乃木坂46",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:80] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/879321670640558081/LJqAoLcs_400x400.jpg"
                            }, @{
                            @"id_str": @"9",
                            @"name": @"@AppleMusic",
                            @"screen_name": @"Apple Music",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:90] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/880580416373223424/nKh04sgE_400x400.jpg"
                            }, @{
                            @"id_str": @"10",
                            @"name": @"@rwenderlich",
                            @"screen_name": @"Ray Wenderlich",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:100] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/481233660322922498/Z3mNN_Ny_400x400.png"
                            }, @{
                            @"id_str": @"11",
                            @"name": @"@v8js",
                            @"screen_name": @"V8",
                            @"create_at": [TWUtils formattedDateString:[NSDate dateWithTimeIntervalSinceNow:110] format:@"E MMM dd HH:mm:ss Z yyyy"],
                            @"profile_url": @"https://pbs.twimg.com/profile_images/881818234621743104/_Iegct3S_400x400.png"
                            }
                        ]};
}

@end
