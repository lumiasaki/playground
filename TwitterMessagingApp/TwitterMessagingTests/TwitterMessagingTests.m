//
//  TwitterMessagingTests.m
//  TwitterMessagingTests
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWMessage.h"
#import "TWUser.h"
#import "TWPersistingManager.h"
#import "TWDialogue.h"

@interface TwitterMessagingTests : XCTestCase

@end

@implementation TwitterMessagingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    NSSet *result = [TWPersistingManager.sharedManager selectObjects:TWDialogue.class predicate:nil];
    for (TWBaseModel *model in result) {
        [TWPersistingManager.sharedManager deleteObject:model];
    }
    [TWPersistingManager.sharedManager save];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testPersiting {
    TWUser *tom = [[TWUser alloc] init];
    tom.userId = @"tomId";
    tom.name = @"tom";
    tom.screenName = @"tom";
    tom.profileUrl = @"tomAvatar";
    
    [TWPersistingManager.sharedManager insertObject:tom];
    
    TWUser *jerry = [[TWUser alloc] init];
    jerry.userId = @"jerryId";
    jerry.name = @"jerry";
    jerry.screenName = @"jerry";
    jerry.profileUrl = @"jerryAvatar";
    
    [TWPersistingManager.sharedManager insertObject:jerry];
    
    [TWPersistingManager.sharedManager save];
    
    TWDialogue *dialog = [[TWDialogue alloc] initWithUserPeer:tom recipient:jerry];
    dialog.recipient = jerry;
    
    [TWPersistingManager.sharedManager insertObject:dialog];
    [TWPersistingManager.sharedManager save];
    
    TWMessage *message = [[TWMessage alloc] init];
    message.messageType = @(1);
    message.timestamp = [NSDate date];
    message.readStatus = @NO;
    message.messageUniqueIdentifier = @"number 1";
    message.sender = tom;
    message.receiver = jerry;
    
    [TWPersistingManager.sharedManager insertObject:message];
    
    TWMessage *message2 = [[TWMessage alloc] init];
    message2.messageType = @(1);
    message2.timestamp = [NSDate dateWithTimeIntervalSinceNow:30];
    message2.readStatus = @NO;
    message2.messageUniqueIdentifier = @"number 2";
    message2.sender = jerry;
    message2.receiver = tom;
    
    [TWPersistingManager.sharedManager insertObject:message2];
    
    [TWPersistingManager.sharedManager save];
    
    dialog.messages = [NSSet setWithArray:@[message, message2]];

    [TWPersistingManager.sharedManager updateObject:dialog];
    [TWPersistingManager.sharedManager save];
    
    NSSet *result = [TWPersistingManager.sharedManager selectObjects:TWDialogue.class predicate:[NSPredicate predicateWithFormat:@"dialogueId = %@", dialog.dialogueId]];
    
    XCTAssert(result.count == 1 && [[(TWDialogue *)result.anyObject recipient].screenName isEqualToString:@"jerry"] && [[result.anyObject messages] count] == 2 && [[result.anyObject lastMessage].messageUniqueIdentifier isEqualToString:@"number 2"]);
}

@end
