//
//  DataSource.m
//  Blocstagram
//
//  Created by Christopher Allen on 9/22/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"
#import <UICKeyChainStore.h>


@interface DataSource () {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@end

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                        // #1
                        for (Media* mediaItem in self.mediaItems) {
                            [self downloadImageForMediaItem:mediaItem];
                        }
                        
                        
                        
                        // as35: work here to auto fetch newer items on load if there are cached mediaItems.  I think it works..  hard to tell.
                        
                        [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:nil];

            
                        
                        // how can I call the refresh method on the ImagesTableViewController?  I'd like the refresher to spin, etc.  ie, access the refresh control and trigger the event from there.  is it possible if ImagesTableVC is not a singleton?
                
                        
                        
                        
                        
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }

    }
    
    return self;
}

- (void) registerForAccessTokenNotification {  // *? research more on notification center.  so there is a central notification center created (where did we create it?) and you add observers for certain notifications, like below here.  so this obj DataSource will enact change upon receiving notification that 'LoginViewControllerDidGetAccessTokenNotification'.  This method addObserverForName:x:x:x also send a block as a param to do stuff over there in the notification center.  Over in LoginVC where notification is posted by postNotificationName:object:, the object param is given the argument of an NSString of the access token which we access w the block passed in here.  (note how the block works as a closure.  you pass it in and the method knows what to do with it (by the API for the method), the param is type NSNotification, used to access the object attr of the notification and effect change.
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        // Got a token; populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}



- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {  // see as34 for your work through of this process
    // #1
    
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        // Add images
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
        
        if (minID) {
            parameters = @{@"min_id": minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {  // confusing completion handler mechanics here because using the same name completionHandler. note that the code block is defined in ImagesTableViewController.m and handed off here to where it's finally used in populateDataWithParameters
            // the completionHandler block code is:  [sender endRefreshing];  waaaay back in imagesTableVC, to stop the whirler if finished or errored out.  like JS closures, encapsulating state of original scope.
            // passing the block on here with another scope closure marker.  like a flag placed on the journey as a reminder.  eventually if there is an error we can enact change in two different scopes.  here in DataSource and over in ImagesTable VC.  here we'll make DataSource set isRefreshing to NO, and in imagestableVC we'll notify the sender (the UIRefreshControl object) that refreshing is over.
            // probably should have different names, to make the two scope blocks easier to differentiate.  like imagesVCCompletionHandler and dataSourceCompletionHandler.
            
            self.isRefreshing = NO;
            
            if (completionHandler) {  // refers to the closure in imagesTableVC
                completionHandler(error);
            }
        }];
    }
}



- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
     if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
        
         NSString *maxID = [[self.mediaItems lastObject] idNumber];
         NSDictionary *parameters;
        
         if (maxID) {
             parameters = @{@"max_id": maxID};
         }
         
         [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
             self.isLoadingOlderItems = NO;
             if (completionHandler) {
                 completionHandler(error);
             }
         }];
    }
}

+ (NSString *) instagramClientID {
    return @"d289c4a8f47a46c894c7c23e4a492407";
}

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler { // "If there's an error, pass it to completionHandler. If the request is successful, pass nil for the error object"  this type definition is just because C is funky/old and you can't pass in parameters (like a block argument) without specifying a type... and since it's just a chunk of code it doesn't have a type really... so you make one up for it, in this case type NewItemCompletionBlock, and we're naming each 'instance' of it here completionHandler.  like (NSString *)someString does.  
    
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    if (feedDictionary) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                
                            if (completionHandler) {
                                completionHandler(nil);
                            }
                        });
                    } else if (completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);  // refers to the closure in DataSource, which enacts change there, and also calls the first completion handler closure way back in ImagesTableVC to enact change there too.  daisy-chaining closures.
                        });
                    }
                } else if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(webError);
                    });
                }
            }
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {  // parse data AND potentially add it to the model
    
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        } else {
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        }
    } else {
        [self willChangeValueForKey:@"mediaItems"];  // ?: what is this
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    [self saveImages];
}

- (void) saveImages {
    
    if (self.mediaItems.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];  // still unsure how that method works (down below) but it's not priority.
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];  // i assume this deletes previously saved mediaItems and bashes them?  automatically, or we did that somewhere..
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
        
    }
}

- (void) downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];  // "This data model update will trigger the KVO notification to reload the individual row in the table view."  reread ch34 assignment to remind abt how the process works method to method
                        
                        [self saveImages];
                    });
                }
            } else {
                NSLog(@"Error downloading image: %@", error);
            }
        });
    }
}

// method to create full path for given filename (when caching for future use of app).  not intuitive, but option-click the params passed in and the method
- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    
//    NSLog(@"data path for filename saving: %@", dataPath);  // testing to see what the path looks like where we're saving mediaItems.  looks like this: /Users/mooncake/Library/Developer/CoreSimulator/Devices/B2EC86BD-8561-4ED4-910E-CE91A79FAA2C/data/Containers/Data/Application/07FA6380-8AD6-43F2-9A58-779109740C4F/Library/Caches/mediaItems
    return dataPath;
}


#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

- (void)deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}








@end
