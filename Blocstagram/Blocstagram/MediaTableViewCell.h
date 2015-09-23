//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Christopher Allen on 9/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;

@end
