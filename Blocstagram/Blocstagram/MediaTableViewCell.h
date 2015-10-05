//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Christopher Allen on 9/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell;

@protocol MediaTableViewCellDelegate <NSObject>

- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id<MediaTableViewCellDelegate> delegate;  // review delegate mechanics

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
