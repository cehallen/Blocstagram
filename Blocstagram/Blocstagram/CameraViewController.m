//
//  CameraViewController.m
//  Blocstagram
//
//  Created by Christopher Allen on 10/21/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CameraToolbar.h"
#import "UIImage+ImageUtilities.h"

@interface CameraViewController () <CameraToolbarDelegate>

@property (nonatomic, strong) UIView *imagePreview;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) NSArray *horizontalLines;
@property (nonatomic, strong) NSArray *verticalLines;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@property (nonatomic, strong) CameraToolbar *cameraToolbar;

@end

@implementation CameraViewController

#pragma mark - Build View Hierarchy

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setupImageCapture];
    [self createCancelButton];
}

- (void) createViews {
    self.imagePreview = [UIView new];
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    self.cameraToolbar = [[CameraToolbar alloc] initWithImageNames:@[@"rotate", @"road"]];
    self.cameraToolbar.delegate = self;
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;  // seems like a double of alpha here and in whiteBG no?
}

- (void) addViewsToViewHierarchy {
    NSMutableArray *views = [@[self.imagePreview, self.topView, self.bottomView] mutableCopy];
    [views addObjectsFromArray:self.horizontalLines];
    [views addObjectsFromArray:self.verticalLines];
    [views addObject:self.cameraToolbar];
    
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}

// a way to give a property a value, by overriding the getters (opposed to saying self.xyz = abc)
- (NSArray *) horizontalLines {
    if (!_horizontalLines) {
        _horizontalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _horizontalLines;
}

- (NSArray *) verticalLines {
    if (!_verticalLines) {
        _verticalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _verticalLines;
}

- (NSArray *) newArrayOfFourWhiteViews {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [array addObject:view];
    }
    
    return array;
}

- (void) setupImageCapture {
    // #1
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // #2
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    // #3
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{  // explain this async version of getting main thread?... I guess it means when the response comes back (for access), then run this.  until then don't block on it and wait.
            // #4
            if (granted) {
                // #5
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                // #6
                NSError *error = nil;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!input) {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        [self.delegate cameraViewController:self didCompleteWithImage:nil];
                    }]];
                    
                    [self presentViewController:alertVC animated:YES completion:nil];
                } else {
                    // #7
                    
                    [self.session addInput:input];
                    
                    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                    self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
                    
                    [self.session addOutput:self.stillImageOutput];
                    
                    [self.session startRunning];  // start running, as in.. stillImageOutput sucks in any available still images from the session input?  don't see input getting assigned
                }
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title")
                                                                                 message:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self.delegate cameraViewController:self didCompleteWithImage:nil];
                }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        });
    }];
}

- (void) createCancelButton {
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - Event Handling

- (void) cancelPressed:(UIBarButtonItem *)sender {  // note the sender is automatically available as a param in button actions.  you could nix the colon in the @selector method and have no params, if you wanted.
    [self.delegate cameraViewController:self didCompleteWithImage:nil];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);  // bottom view is what's left after the 44px tall topView and image square below it
    
    CGFloat thirdOfWidth = width / 3;
    
    for (int i = 0; i < 4; i++) {
        UIView *horizontalLine = self.horizontalLines[i];
        UIView *verticalLine = self.verticalLines[i];
        
        horizontalLine.frame = CGRectMake(0, (i * thirdOfWidth) + CGRectGetMaxY(self.topView.frame), width, 0.5);
        
        CGRect verticalFrame = CGRectMake(i * thirdOfWidth, CGRectGetMaxY(self.topView.frame), 0.5, width);
        
        if (i == 3) {  // why?  to make it visible, not literally the right edge of the screen.  the bottom horizontal line doesn't need it bc the translucent view there shows it through
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
    }
    
    self.imagePreview.frame = self.view.bounds;  // I think this is the whole screen.  we just have to crop to a square later
    self.captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolbarHeight = 100;
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolbarHeight, width, cameraToolbarHeight);
}

// don't forget these button methods are declared back in the delegator (CameraToolbar).  specifically in the buttons' action selectors
#pragma mark - CameraToolbarDelegate

// flipping the cameras front-rear
- (void) leftButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 1) {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex + 1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        if (newVideoInput) {  // this 'fakeView' is just a snapshot of what the first device was seeing, which is inserted above the imagePreview, then devices switched, then the fakeView is animated away.  all that to give the switch an animation not just a snap second change of views
            UIView *fakeView = [self.imagePreview snapshotViewAfterScreenUpdates:YES];
            fakeView.frame = self.imagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.imagePreview];
            
            [self.session beginConfiguration];
            [self.session removeInput:currentCameraInput];
            [self.session addInput:newVideoInput];
            [self.session commitConfiguration];
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                fakeView.alpha = 0;  // this is the dissolve effect, as the alpha goes to 0 over 0.2 seconds
            } completion:^(BOOL finished) {
                [fakeView removeFromSuperview];
            }];
        }
    }
}

- (void) rightButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    NSLog(@"Photo library button pressed.");
}

- (void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    AVCaptureConnection *videoConnection;
    
    // #8
    // Find the right connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    // #9
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer) {
            // #10
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            
            // #11
            image = [image imageWithFixedOrientation];
            image = [image imageResizedToMatchAspectRatioOfSize:self.captureVideoPreviewLayer.bounds.size];
            
            // #12
            UIView *leftLine = self.verticalLines.firstObject;
            UIView *rightLine = self.verticalLines.lastObject;
            UIView *topLine = self.horizontalLines.firstObject;
            UIView *bottomLine = self.horizontalLines.lastObject;
            
            CGRect gridRect = CGRectMake(CGRectGetMinX(leftLine.frame),
                                         CGRectGetMinY(topLine.frame),
                                         CGRectGetMaxX(rightLine.frame) - CGRectGetMinX(leftLine.frame),
                                         CGRectGetMinY(bottomLine.frame) - CGRectGetMinY(topLine.frame));
            
            CGRect cropRect = gridRect;
            cropRect.origin.x = (CGRectGetMinX(gridRect) + (image.size.width - CGRectGetWidth(gridRect)) / 2);
            
            image = [image imageCroppedToRect:cropRect];
            
            // #13
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraViewController:self didCompleteWithImage:image];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self.delegate cameraViewController:self didCompleteWithImage:nil];
                }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            });
            
        }
    }];
}



/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
