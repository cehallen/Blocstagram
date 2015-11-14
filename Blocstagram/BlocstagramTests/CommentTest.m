//
//  CommentTest.m
//  Blocstagram
//
//  Created by Christopher Allen on 11/14/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Comment.h"

@interface CommentTest : XCTestCase

@end

@implementation CommentTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitialization {
//    @"comments" : @{@"data" : @[@"Sample comments", @"Comment 2"]}
    NSDictionary *commentDictionary = @{
                                    @"id" : @"23432",
                                    @"text" : @"comment text"
                                };
    Comment *testComment = [[Comment alloc] initWithDictionary:commentDictionary];
    
    XCTAssertEqualObjects(testComment.idNumber, commentDictionary[@"id"], @"Comment ids should be equal");
    XCTAssertEqualObjects(testComment.text, commentDictionary[@"text"], @"Comment texts should be equal");
}


@end
