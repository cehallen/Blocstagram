//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Christopher Allen on 10/5/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

// as36 add button to parallel with longPressGesture's action of showing UIActivityController
@property (nonatomic, strong) UIButton *shareButton;

- (instancetype) initWithMedia:(Media *)media;

- (void) centerScrollView;



@end
