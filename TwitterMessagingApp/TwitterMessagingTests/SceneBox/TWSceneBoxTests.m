//
//  TWSceneBoxTests.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/27.
//  Copyright © 2020 tianren.zhu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWSceneBox.h"
#import "TWSceneBoxUnitTestHelperExtension.h"
#import "TWSceneBoxExecutor.h"
#import "TWSceneBoxTestSceneStateTable.h"
#import "TWSceneBoxTestSceneViewController.h"

@interface TWSceneBoxTests : XCTestCase

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) TWSceneBoxConfiguration *configuration;
@property (nonatomic, strong) TWSceneBoxUnitTestHelperExtension *unitTestExtension;
@property (nonatomic, strong) TWSceneBox *sceneBox;

@property (nonatomic, strong) TWSceneBoxTestSceneViewController *scene1;
@property (nonatomic, strong) TWSceneBoxTestSceneViewController *scene2;

@end

@implementation TWSceneBoxTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.navigationController = [[UINavigationController alloc] init];
    
    self.configuration = [[TWSceneBoxConfiguration alloc] init];
    self.configuration.navigationController = self.navigationController;
    
    self.unitTestExtension = [[TWSceneBoxUnitTestHelperExtension alloc] init];
    [self.configuration setExtension:self.unitTestExtension];
    
    self.sceneBox = [[TWSceneBox alloc] initWithConfiguration:self.configuration entryBlock:^(UIViewController<TWSceneBoxScene> * _Nonnull scene, TWSceneBox * _Nonnull sceneBox) {
        [self.navigationController pushViewController:scene animated:YES];
    } exitBlock:^(UIViewController<TWSceneBoxScene> * _Nonnull scene, TWSceneBox * _Nonnull sceneBox) {
        // keep empty
    }];
    
    self.scene1 = [[TWSceneBoxTestSceneViewController alloc] init];
    self.scene2 = [[TWSceneBoxTestSceneViewController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.configuration = nil;
    self.unitTestExtension = nil;
}

- (void)testBasicLifeCyclesOfSceneBox {
    NSUUID *scene1Identifier = [self.sceneBox addScene:self.scene1];
    XCTAssertTrue([scene1Identifier isKindOfClass:NSUUID.class]);
    
    self.sceneBox.stateSceneIdentifierTable = @{
        @(TWSceneBoxNavigationExtension.entryState) : scene1Identifier
    };
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"scene box life cycle hooks"];
    expectation.expectedFulfillmentCount = 2;
    
    self.unitTestExtension.sceneBoxWillTerminateBlock = ^{
        [expectation fulfill];
    };
    
    self.unitTestExtension.extensionDidMountBlock = ^{
        [expectation fulfill];
    };
    
    [TWSceneBoxExecutor.shared executeBox:self.sceneBox];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scene1 transitToState:@(TWSceneBoxNavigationExtension.terminationState)];
    });
    
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testBasicLifeCyclesOfScene {
    NSUUID *scene1Identifier = [self.sceneBox addScene:self.scene1];
    XCTAssertTrue([scene1Identifier isKindOfClass:NSUUID.class]);
    
    NSUUID *scene2Identifier = [self.sceneBox addScene:self.scene2];
    XCTAssertTrue([scene2Identifier isKindOfClass:NSUUID.class]);
    
    self.sceneBox.stateSceneIdentifierTable = @{
        @(TWSceneBoxNavigationExtension.entryState) : scene1Identifier,
        @(TWSceneBoxTestSceneStateTableScene2) : scene2Identifier
    };
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"scene life cycle hooks"];
    expectation.expectedFulfillmentCount = 6;
    
    __block NSTimeInterval scene1Load;
    self.scene1.sceneDidLoadedBlock = ^{
        scene1Load = NSDate.date.timeIntervalSince1970;
        [expectation fulfill];
    };
    
    __block NSTimeInterval scene1Unload;
    self.scene1.sceneWillUnloadBlock = ^{
        scene1Unload = NSDate.date.timeIntervalSince1970;
        [expectation fulfill];
    };
    
    __block NSTimeInterval scene2Load;
    self.scene2.sceneDidLoadedBlock = ^{
        scene2Load = NSDate.date.timeIntervalSince1970;
        [expectation fulfill];
    };
    
    __block NSTimeInterval scene2Unload;
    self.scene2.sceneWillUnloadBlock = ^{
        scene2Unload = NSDate.date.timeIntervalSince1970;
        [expectation fulfill];
    };
    
    [TWSceneBoxExecutor.shared executeBox:self.sceneBox];
    
    XCTAssertTrue([self.scene1 isActiveScene]);
    XCTAssertFalse([self.scene2 isActiveScene]);
    
    self.unitTestExtension.navigationTrackBlock = ^(NSNumber * _Nonnull from, NSNumber * _Nonnull to) {
        XCTAssert(from.integerValue == TWSceneBoxNavigationExtension.entryState);
        XCTAssert(to.integerValue == @(TWSceneBoxTestSceneStateTableScene2).integerValue);
        
        [expectation fulfill];
    };
    [self.scene1 transitToState:@(TWSceneBoxTestSceneStateTableScene2)];
    
    // simulate user interaction
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertFalse([self.scene1 isActiveScene]);
        XCTAssertTrue([self.scene2 isActiveScene]);
        self.unitTestExtension.navigationTrackBlock = ^(NSNumber * _Nonnull from, NSNumber * _Nonnull to) {
            XCTAssert(from.integerValue == @(TWSceneBoxTestSceneStateTableScene2).integerValue);
            XCTAssert(to.integerValue == TWSceneBoxNavigationExtension.terminationState);
            
            XCTAssertTrue(scene1Load < scene1Unload);
            XCTAssertTrue(scene1Unload < scene2Load);
            XCTAssertTrue(scene2Load < scene2Unload);
            
            [expectation fulfill];
        };
        [self.scene1 transitToState:@(TWSceneBoxNavigationExtension.terminationState)];
    });
    
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testLazyAddSceneAndGetScenes {
    NSUUID *scene1Identifier = NSUUID.UUID;
    NSUUID *scene2Identifier = NSUUID.UUID;
    
    __weak typeof(self) weakSelf = self;
    [self.sceneBox lazyAddScene:^UIViewController<TWSceneBoxScene> * _Nonnull{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        return strongSelf.scene1;
    } sceneIdentifier:scene1Identifier];
    
    [self.sceneBox lazyAddScene:^UIViewController<TWSceneBoxScene> * _Nonnull{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        return strongSelf.scene2;
    } sceneIdentifier:scene2Identifier];
    
    self.sceneBox.stateSceneIdentifierTable = @{
        @(TWSceneBoxNavigationExtension.entryState) : scene1Identifier,
        @(TWSceneBoxTestSceneStateTableScene2) : scene2Identifier
    };
    
    [TWSceneBoxExecutor.shared executeBox:self.sceneBox];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
    expectation.assertForOverFulfill = 1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(self.unitTestExtension.getScenesBlock().count == 1);
        
        NSUUID *scene1 = self.unitTestExtension.getScenesBlock().firstObject;
        XCTAssertTrue([scene1 isKindOfClass:NSUUID.class]);
        XCTAssertTrue([scene1 isEqual:scene1Identifier]);
        
        XCTAssertTrue([self.scene1 isActiveScene]);
        XCTAssertFalse([self.scene2 isActiveScene]);
        
        [self.scene1 transitToState:@(TWSceneBoxTestSceneStateTableScene2)];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{            
            XCTAssertTrue(self.unitTestExtension.getScenesBlock().count == 2);
            
            XCTAssertFalse([self.scene1 isActiveScene]);
            XCTAssertTrue([self.scene2 isActiveScene]);
            
            [self.scene2 transitToState:@(TWSceneBoxNavigationExtension.terminationState)];
            [expectation fulfill];
        });
    });
    
    [self waitForExpectations:@[expectation] timeout:20];
}

- (void)testNavigationExtension {
    NSUUID *scene1Identifier = [self.sceneBox addScene:self.scene1];
    
    NSUUID *scene2Identifier = NSUUID.UUID;
    [self.sceneBox lazyAddScene:^UIViewController<TWSceneBoxScene> * _Nonnull{
        return self.scene2;
    } sceneIdentifier:scene2Identifier];
    
    self.sceneBox.stateSceneIdentifierTable = @{
        @(TWSceneBoxNavigationExtension.entryState) : scene1Identifier,
        @(TWSceneBoxTestSceneStateTableScene2) : scene2Identifier
    };
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
    expectation.expectedFulfillmentCount = 5;
    
    [TWSceneBoxExecutor.shared executeBox:self.sceneBox];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(self.unitTestExtension.getScenesBlock().count == 1);
                
        self.unitTestExtension.navigationTrackBlock = ^(NSNumber * _Nonnull from, NSNumber * _Nonnull to) {
            XCTAssertTrue([from isEqual:@(TWSceneBoxNavigationExtension.entryState)]);
            XCTAssertTrue([to isEqual:@(TWSceneBoxTestSceneStateTableScene2)]);
            [expectation fulfill];
        };
        [self.scene1 transitToState:@(TWSceneBoxTestSceneStateTableScene2)];
        
        // simulate user interactions
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssertTrue(self.unitTestExtension.getScenesBlock().count == 2);
            self.unitTestExtension.navigationTrackBlock = nil;
            self.unitTestExtension.navigationTrackBlock = ^(NSNumber * _Nonnull from, NSNumber * _Nonnull to) {
                XCTAssertTrue([from isEqual:@(TWSceneBoxTestSceneStateTableScene2)]);
                XCTAssertTrue([to isEqual:@(TWSceneBoxNavigationExtension.entryState)]);
                [expectation fulfill];
            };
            [self.scene1 transitToState:@(TWSceneBoxNavigationExtension.entryState)];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.unitTestExtension.navigationTrackBlock = nil;
                XCTAssertTrue(self.unitTestExtension.getScenesBlock().count == 1);
                XCTAssertTrue([self.scene1 isActiveScene]);
                XCTAssertFalse([self.scene2 isActiveScene]);
                
                [expectation fulfill];
                
                [self.scene1 transitToState:@(TWSceneBoxTestSceneStateTableScene2)];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    XCTAssertTrue(self.unitTestExtension.getScenesBlock().count == 2);
                    XCTAssertFalse([self.scene1 isActiveScene]);
                    XCTAssertTrue([self.scene2 isActiveScene]);
                    
                    [expectation fulfill];
                    
                    [self.scene2 transitToPreviousSceneState];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        XCTAssertTrue(self.unitTestExtension.getScenesBlock().count == 1);
                        XCTAssertTrue([self.scene1 isActiveScene]);
                        XCTAssertFalse([self.scene2 isActiveScene]);
                        
                        [expectation fulfill];
                    });
                });
            });
        });
    });
    
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testSharedStateExtension {
    NSUUID *scene1Identifier = [self.sceneBox addScene:self.scene1];
    NSUUID *scene2Identifier = [self.sceneBox addScene:self.scene2];
    
    self.sceneBox.stateSceneIdentifierTable = @{
        @(TWSceneBoxNavigationExtension.entryState) : scene1Identifier,
        @(TWSceneBoxTestSceneStateTableScene2) : scene2Identifier
    };
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
    expectation.expectedFulfillmentCount = 1;
    
    [TWSceneBoxExecutor.shared executeBox:self.sceneBox];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSNumber *sharedOne = @1;
        NSString *sharedOneKey = @"count";
        
        {
            self.scene1.putSharedState(sharedOne, sharedOneKey);
            NSNumber *fetchFromSharedState = self.scene1.getSharedStateBy(sharedOneKey);
            
            XCTAssertTrue([fetchFromSharedState isEqualToNumber:sharedOne]);
        }
                        
        [self.scene1 transitToState:@(TWSceneBoxTestSceneStateTableScene2)];
        
        {
            NSNumber *fetchFromSharedState = self.scene2.getSharedStateBy(sharedOneKey);
            XCTAssertTrue([fetchFromSharedState isEqualToNumber:sharedOne]);
        }
        
        [self.scene2 transitToState:@(TWSceneBoxNavigationExtension.terminationState)];
        
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10];
}

@end
