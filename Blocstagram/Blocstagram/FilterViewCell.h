//
//  FilterViewCell.h
//  Blocstagram
//
//  Created by Christopher Allen on 10/31/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class FilterViewCell;

// as43 - don't think I need these since there are no new methods in this subclass...  just some properties right?

@protocol FilterViewCellDelegate <NSObject>



@end

@interface FilterViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) id<FilterViewCellDelegate> delegate;

@end
