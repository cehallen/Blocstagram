//
//  FilterViewCell.h
//  Blocstagram
//
//  Created by Christopher Allen on 11/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewCell : UICollectionViewCell

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;

@end
