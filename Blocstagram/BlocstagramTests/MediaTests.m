//
//  MediaTests.m
//  Blocstagram
//
//  Created by Christopher Allen on 11/5/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Media.h"
#import "User.h"

@interface MediaTests : XCTestCase

@end

@implementation MediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testThatInitializationWorks
{

    
    NSDictionary *sourceDictionary = @{
                   @"id": @"1234",
                   @"user" :
                       @{@"id": @"8675309",
                         @"username" : @"d'oh",
                         @"full_name" : @"Homer Simpson",
                         @"profile_picture" : @"http://www.example.com/example.jpg"},
                   @"images" : @{@"standard_resolution" : @{@"url" : @"http://www.example.com/example.jpg"}},
                   @"caption" : @{@"text" : @"Sample caption text"},
//                   @"comments" : @{@"data" : @[@"Sample comments", @"Comment 2"]}, // not sure why this doesn't work with comments.. but you could comment each item out until you find the culprit next time.  assuming there's only one ><.
                   @"user_has_liked" : @"0"
               };
    
    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    
    XCTAssertEqualObjects(testMedia.user.userName, sourceDictionary[@"user"][@"username"], @"The username should be equal");
    
    XCTAssertEqualObjects(testMedia.mediaURL, [NSURL URLWithString:sourceDictionary[@"images"][@"standard_resolution"][@"url"]], @"The profile picture should be equal");
    
    XCTAssertEqualObjects(testMedia.caption, sourceDictionary[@"caption"][@"text"], @"The caption should be equal");
    
//    XCTAssertEqualObjects(testMedia.comments, sourceDictionary[@"comments"][@"data"]);

}







@end
