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


// delegate notes from ch25: "it implements a delegate protocol, so classes can be optionally informed when one of the titles (here is view cell) is pressed".  so who are we notifying?  ie who are the delegates?  ImagesTableVC, which conforms to this protocol by the line in it:  `@interface ImagesTableViewController () <MediaTableViewCellDelegate>`  the angle brackes part added.  does that line alone set it as the delegate?  i think it only says "i follow it's protocol".  and of course import the class in with `#import "MediaFullScreenViewController.h"`
// from ch25: "One optional delegate method is declared. If the delegate implements it, it will be called when a user taps a button."  in this case, these two methods are protocol, and if the delegate implements them they'll run when self here is tapped or long pressed.  notice they are defined over in the ImagesTableVC.  that is the delegate.
// how are these methods registered here though?  ie, how do we get them to run over there on tap here.
/* here's how, in .m:
     - (void) tapFired:(UITapGestureRecognizer *)sender {
        [self.delegate cell:self didTapImageView:self.mediaImageView];
     }
 */
// where is ImagesTableVC set as the delegate though?  can't find any code saying `self.delegate = ...`  FOUND IT:
/* in ImagesTableVC.m line ~132
     - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
         MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
         cell.delegate = self;
         cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
         return cell;
     }
 */
- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id<MediaTableViewCellDelegate> delegate;
// review delegate mechanics. good apple docs explanation:
// "The pie chart view [MediaTableViewCell] class interface would need a property to keep track of the data source [ImagesTableVC] object. This object could be of any class, so the basic property type will be id. The only thing that is known about the object is that it conforms to the relevant protocol."
// "Objective-C uses angle brackets to indicate conformance to a protocol. This example declares a weak property for a generic object pointer that conforms to the XYZPieChartViewDataSource [MediaTableViewCellDelegate] protocol."
// it's marked as 'weak' to avoid a strone reference cycle.  when the delegate gives up relationship to our cell here, there will be no strong reference from here to the delegate obj, which will be deallocated along with the media cell here.  anyway, read their docs.

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
