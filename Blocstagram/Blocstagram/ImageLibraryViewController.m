//
//  ImageLibraryViewController.m
//  Blocstagram
//
//  Created by Christopher Allen on 10/25/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "ImageLibraryViewController.h"
#import <Photos/Photos.h>
#import "CropImageViewController.h"

@interface ImageLibraryViewController () <CropImageViewControllerDelegate>

@property (nonatomic, strong) PHFetchResult *result;

@end

@implementation ImageLibraryViewController

- (instancetype) init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void) cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate imageLibraryViewController:self didCompleteWithImage:nil];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat minWidth = 80; // as42b (was 100)
    NSInteger divisor = width / minWidth;
    CGFloat cellSize = (width / divisor) - 1;  // as42b added " - 1".  Not perfect, since there is one extra pixel on the last image item.
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(cellSize, cellSize);
    flowLayout.minimumInteritemSpacing = 1; // as42b was 0
    flowLayout.minimumLineSpacing = 1; // as42b was 0
}

- (void) loadAssets {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{  // how is this possible, unless... we weren't on the main thread to begin with?  that must be it, because how else can you run async from the main queue, on the main queue??  (the main thread is serial by nature.. can't do concurrency).  this kind of makes sense now, since UI changes should be done on the main queue (they say)
                    [self loadAssets];
                    [self.collectionView reloadData];
                });
            }
        }];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self loadAssets];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.result.count;
}

// "To make the scrolling smoother, we'll get the image asynchronously and update the cell's image view when it arrives. This is the same pattern we use when downloading images from Instagram - return cell as soon as possible, and then update it when the image arrives:"
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSInteger imageViewTag = 54321;
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.tag = imageViewTag;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
    }
    
    if (cell.tag != 0) { // don't get this
        [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    PHAsset *asset = self.result[indexPath.row];
    
    cell.tag = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        UICollectionViewCell *cellToUpdate = [collectionView cellForItemAtIndexPath:indexPath];
        
        if (cellToUpdate) { // this is funky to me.  it's done so you can reuse..  but I don't fully get the arbitrary tag name thing.  A: each cell, when created can have multiple image views (in the contentView of the cell) attached, and those image views are retrieved by tag (as you see below).  so every cell that's been made while scrolling has a tag 54321.  when you're in that cell and want to attach an image you get the 'right' image view (even though we'll only ever have one in each cell) by calling it with it's tag.  then you set the imageView's image as 'result'.  
            UIImageView *imageView = (UIImageView *)[cellToUpdate.contentView viewWithTag:imageViewTag];
            imageView.image = result;
        }
    }];
    
    return cell;
}


// "When the user taps a thumbnail, get the full resolution image and pass it to the crop controller:"
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.result[indexPath.row];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *resultImage, NSDictionary *info)
     {
         CropImageViewController *cropVC = [[CropImageViewController alloc] initWithImage:resultImage];
         cropVC.delegate = self;
         [self.navigationController pushViewController:cropVC animated:YES];
     }];
}

#pragma mark - CropImageViewControllerDelegate

// "When the user crops an image, we'll inform delegate:"  (delegate here is CameraViewController, [which has it's own delegate of ImagesTableVC])
- (void) cropControllerFinishedWithImage:(UIImage *)croppedImage {
    [self.delegate imageLibraryViewController:self didCompleteWithImage:croppedImage];
}





@end
