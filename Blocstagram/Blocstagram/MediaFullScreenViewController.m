//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Christopher Allen on 10/5/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"  // we'll start by importing 'media' and creating a property to store it.  could your problem with importing ImagesTableVC in as35 be this simple (you want to access that specific instance of it, not make a new one).  you must learn more what's happening behind the scenes here wrt instance and memory and pointers.
// as36:
#import "MediaTableViewCell.h"

@interface MediaFullScreenViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Media *media;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation MediaFullScreenViewController

- (instancetype) initWithMedia:(Media *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;  // not sure about where this 'self' is returned to.  I guess appDelegate, somehow.  don't see any linking to it though
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;  // this instance of 'media'.. where does it come from.  I assume now ever media item will have a link to one of this class, and be set up over in Media?  fuzzy on importing Media and making these links.  simplify it down to a delegate relationship if you can.
    
    [self.scrollView addSubview:self.imageView];
    
    self.scrollView.contentSize = self.media.image.size;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    
    
    // as36: button to piggyback on share action already made
    // must implement an action for a selector over in MediaTableViewCell (longPressFired:).  problem is how to do it.
    /*
     - import MediaTableViewCell.h to this .m file  √
     - set longPressFired as action on our shareButton here √
     - make longPressFired public by putting into its .h file?  √
     - should I make the 'target' not self, but instead the MediaTableViewCell?
     */
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
    self.shareButton.backgroundColor = [UIColor grayColor];
    [self.shareButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.shareButton];
    
    
    
    
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];  // did we always do this in viewWillLayoutSubviews?
    
    self.scrollView.frame = self.view.bounds;
    
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;
    
    
    // as36: button layout
//    CGFloat buttonHeight = CGRectGetHeight(self.view.bounds) / 8;
//    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 8;
    CGFloat buttonX = CGRectGetWidth(self.view.bounds) - 60;
    CGFloat buttonY = 25;
    self.shareButton.frame = CGRectMake(buttonX, buttonY, 50, 20);
}

- (void) centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self centerScrollView];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}

#pragma mark - Gesture Recognizers

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

- (void) shareTapped {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (self.imageView.image) {
        [itemsToShare addObject:self.imageView.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
