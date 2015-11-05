//
//  FilterViewCell.m
//  Blocstagram
//
//  Created by Christopher Allen on 10/31/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "FilterViewCell.h"

@implementation FilterViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        static NSInteger imageViewTag = 1000;
        static NSInteger labelTag = 1001;
        
        UIImageView *thumbnail = (UIImageView *)[self.contentView viewWithTag:imageViewTag];
        UILabel *label = (UILabel *)[self.contentView viewWithTag:labelTag];
        
        CGFloat thumbnailEdgeSize = self.flowLayout.itemSize.width;
        
        thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        thumbnail.tag = imageViewTag;
        thumbnail.clipsToBounds = YES;
        [self.contentView addSubview:thumbnail];
    
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        label.tag = labelTag;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [self.contentView addSubview:label];
        
        thumbnail.image = self.image;
        label.text = self.text;
    }
    
    return self;
}


//- (void)setText:(NSString *)text {
//    static NSInteger labelTag = 1001;
//    
//    UILabel *label = (UILabel *)[self.contentView viewWithTag:labelTag];
//    CGFloat thumbnailEdgeSize = self.flowLayout.itemSize.width;
//    
//    label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
//    label.tag = labelTag;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
//    [self.contentView addSubview:label];
//    
//    _text = text;
//    label.text = _text;
//}
//
//- (void)setImage:(UIImage *)image {
//    static NSInteger imageViewTag = 1000;
//    UIImageView *thumbnail = (UIImageView *)[self.contentView viewWithTag:imageViewTag];
//    CGFloat thumbnailEdgeSize = self.flowLayout.itemSize.width;
//    
//    thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
//    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
//    thumbnail.tag = imageViewTag;
//    thumbnail.clipsToBounds = YES;
//    [self.contentView addSubview:thumbnail];
//    
//    _image = image;
//    thumbnail.image = _image;
//}















@end
