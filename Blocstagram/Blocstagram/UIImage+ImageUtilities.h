//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Christopher Allen on 10/22/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *) imageWithFixedOrientation;
- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *) imageCroppedToRect:(CGRect)cropRect;

@end

@interface UIImage (ImageUtilities)

@end
