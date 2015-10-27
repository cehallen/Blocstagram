//
//  CropImageViewController.m
//  Blocstagram
//
//  Created by Christopher Allen on 10/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropBox.h"
#import "Media.h"
#import "UIImage+ImageUtilities.h"

@interface CropImageViewController()

@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;

// as42
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

// dummy you thought you had to declare private methods here.  nah.. just properties.  methods declared in .h only if they are going public.  here it works just like any program file.  finds it on the page.  not sure if order matters.  probably some hoisting stuff going on.

@end

@implementation CropImageViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.media = [[Media alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [CropBox new];
        
        // as 42
        self.topView = [UIToolbar new];
        self.bottomView = [UIToolbar new];
        UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
        self.topView.barTintColor = whiteBG;
        self.bottomView.barTintColor = whiteBG;
        self.topView.alpha = 0.5;
        self.bottomView.alpha = 0.5;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    // as42
    //    [self.view addSubview:self.cropBox];
    NSMutableArray *views = [@[self.cropBox, self.topView, self.bottomView] mutableCopy];
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect cropRect = CGRectZero;
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    cropRect.size = CGSizeMake(edgeSize, edgeSize);
    
    CGSize size = self.view.frame.size;
    
    self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.clipsToBounds = NO;
    
    [self recalculateZoomScale];
    
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
    
    // as42
    self.topView.frame = CGRectMake(0, 0, edgeSize, CGRectGetMinY(self.cropBox.frame));
    CGFloat bottomViewHeight = CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.cropBox.frame);
    self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.cropBox.frame), edgeSize, bottomViewHeight);
}

- (void) cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
}


@end
