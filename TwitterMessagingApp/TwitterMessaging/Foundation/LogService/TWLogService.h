//
//  TWLogService.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2019/1/9.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLogLevelObserver.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, TWLogLevel) {
    TWLogLevelDebug = 1,
    TWLogLevelInfo = 1 << 1,
    TWLogLevelWarn = 1 << 2,
    TWLogLevelError = 1 << 3,
    TWLogLevelFatal = 1 << 4,
    
    TWLogLevelAll = TWLogLevelDebug | TWLogLevelInfo | TWLogLevelWarn | TWLogLevelError | TWLogLevelFatal
};

@interface TWLogInformation : NSObject <NSCopying>

@property (nonatomic, assign) TWLogLevel logLevel;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *extraInfo;
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

@end

@interface TWLogInformation (TWLogLevelLiteral)

- (NSString *)logLevelLiteral;

@end

@interface TWLogService : NSObject

- (void)registerObserver:(id<TWLogLevelObserver>)observer onLevel:(TWLogLevel)level;
- (void)setUpDone;

- (void)receivedInformation:(TWLogInformation *)information;

@end

NS_ASSUME_NONNULL_END
