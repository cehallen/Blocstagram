//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Christopher Allen on 10/22/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

// as41: I'd like to move these to private methods, but couldn't set up an interface in the .m file.  (different syntax than regular doubled interfaces.)
- (UIImage *) imageWithFixedOrientation;
- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *) imageCroppedToRect:(CGRect)cropRect;

// as41
- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end


