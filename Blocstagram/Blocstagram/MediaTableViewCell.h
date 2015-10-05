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
- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id<MediaTableViewCellDelegate> delegate;  // review delegate mechanics.  i *believe* self here is the delegating obj while the delegate is _______, and we're getting a ref to that delegate through this property.  try again:  I think the media cell is the delegating obj while the MediaFullScreenVC is the delegate.  (it is the one which zooms in on a scroll view, etc).  so you see this property here (line 23).  over all doesn't make sense still.  

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
