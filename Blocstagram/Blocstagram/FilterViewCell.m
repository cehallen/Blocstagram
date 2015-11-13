//
//  FilterViewCell.m
//  Blocstagram
//
//  Created by Christopher Allen on 11/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "FilterViewCell.h"



@implementation FilterViewCell

- (void)layoutSubviews {
    self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.thumbnailEdgeSize, self.thumbnailEdgeSize)];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnail.clipsToBounds = YES;
    [self.contentView addSubview:self.thumbnail];

    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.thumbnailEdgeSize, self.thumbnailEdgeSize, 20)];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
    [self.contentView addSubview:self.label];
}

//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    
//    if (self) {
//        
//    
// //        CGFloat thumbnailEdgeSize = self.flowLayout.itemSize.width;
//
//        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.thumbnailEdgeSize, self.thumbnailEdgeSize)];
//        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
//        self.thumbnail.clipsToBounds = YES;
//        self.thumbnail.backgroundColor = [UIColor redColor];
//        [self.contentView addSubview:self.thumbnail];
//    
//
//
//        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.thumbnailEdgeSize, self.thumbnailEdgeSize, 20)];
//        self.label.textAlignment = NSTextAlignmentCenter;
//        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
//        self.label.backgroundColor = [UIColor greenColor];
//        [self.contentView addSubview:self.label];
//    
//
//    }
//    
//    NSLog(@"filter view cell initialized");
//    
//    return self;
//}

@end
