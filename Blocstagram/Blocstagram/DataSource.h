//
//  DataSource.h
//  Blocstagram
//
//  Created by Christopher Allen on 9/22/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

- (void)deleteMediaItem:(Media *)item;

// (as31:)
- (void) switchRowOf:(Media *)item fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
