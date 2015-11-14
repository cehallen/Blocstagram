//
//  Comment.m
//  Blocstagram
//
//  Created by Christopher Allen on 9/22/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

- (instancetype) initWithDictionary:(NSDictionary *)commentDictionary {
    self = [super init];  // notice how you can override the vanilla init and customize it even customize the name (initWithDictionary isn't out of the box iOS).  how do we know it is called then??  A: it's called in Media.m!!  so we declare the method initWithDict in .h, define it here in .m, and call it somewhere else to make a comment (in Media.m).  ie, just like any other method.  tada.  with the important difference we call the superclass's init, to make sure we get all the NSObject characteristics we need too.  
    
    if (self) {
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[User alloc] initWithDictionary:commentDictionary[@"from"]];
    }
    
    return self;
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];  // remind yourself why you do this step? 
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        self.from = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(from))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
    [aCoder encodeObject:self.from forKey:NSStringFromSelector(@selector(from))];
}

@end
