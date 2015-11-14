//
//  ComposeCommentTest.m
//  Blocstagram
//
//  Created by Christopher Allen on 11/14/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ComposeCommentView.h"

@interface ComposeCommentTest : XCTestCase

@end

@implementation ComposeCommentTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetTextIsWritingComment {
    // This is an example of a functional test case.
    
    ComposeCommentView *testCommentViewOne = [[ComposeCommentView alloc] init];
    [testCommentViewOne setText:@"test text"];
    
    ComposeCommentView *testCommentViewTwo = [[ComposeCommentView alloc] init];
    [testCommentViewTwo setText:@""];
    
    XCTAssertTrue(testCommentViewOne.text, @"this should be true");
    XCTAssertTrue([testCommentViewTwo.text length] == 0, @"this should be true (empty string or nil)");
    
    
}

@end
