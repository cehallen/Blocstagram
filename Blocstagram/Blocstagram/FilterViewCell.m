//
//  FilterViewCell.m
//  Blocstagram
//
//  Created by Christopher Allen on 11/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "FilterViewCell.h"



@implementation FilterViewCell

- (instancetype)init {
    self = [super init];
    
    if (self) {
        static NSInteger imageViewTag = 1000;
        static NSInteger labelTag = 1001;
    
        CGFloat thumbnailEdgeSize = self.flowLayout.itemSize.width;

        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.tag = imageViewTag;
        self.thumbnail.clipsToBounds = YES;
//        self.thumbnail.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.thumbnail];
    


        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        self.label.tag = labelTag;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
//        self.thumbnail.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:self.label];
    

    }
    
    NSLog(@"filter view cell initialized");
    
    return self;
}

@end
