//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Christopher Allen on 9/23/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "LikeButton.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;
// as39
@property (nonatomic, strong) UILabel *likesLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;
// as39
//@property (nonatomic, strong) NSLayoutConstraint *likesLabelHeightConstraint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) LikeButton *likeButton;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;

@implementation MediaTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
    
    // Configure the view for the selected state
}

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; /*#58506d*/
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];  // where does these arguments come from?  ie, where are we manually calling this with arguments?  or are the arguments automatic too
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        // as39
        self.likesLabel = [[UILabel alloc] init];
        self.likesLabel.numberOfLines = 0;
//        self.likesLabel.backgroundColor = usernameLabelGray;
        self.likesLabel.backgroundColor = [UIColor greenColor];
        // http://stackoverflow.com/questions/16009405/uilabel-sizetofit-doesnt-work-with-autolayout-ios6
        // note that with autolayout, if sides, width, or top are pinned, the height will automatically grow and shrink vertically to fit contents...
        // so what's happening here?  not shrinking
//        [self.likesLabel sizeToFit];
        

        
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
//        self.likeButton.backgroundColor = usernameLabelGray;
        self.likeButton.backgroundColor = [UIColor yellowColor];
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.likesLabel]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        
        // (visual format string way to 'visually' layout with auto-layout.  notice you refer to the IVAR here not the property...  still unclear about when to use IVAR's, except when overriding the getter or setter methods a la ch29)
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _likesLabel);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likesLabel(==38)][_likeButton(==38)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary]];  // √

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]" options:kNilOptions metrics:nil views:viewDictionary]];
        
        // as39
//        self.likesLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_likesLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
//        self.likesLabelHeightConstraint.identifier = @"Likes label height constraint";
        
        // (height constraints being set by plopping into the items made above.. ?)
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption label height constraint";
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        self.commentLabelHeightConstraint.identifier = @"Comment label height constraint";
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint/*, self.likesLabelHeightConstraint*/]];

    }
    return self;
}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {  // (ch29: when is this getting called??)
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
//    // Set it to the given width, and the maximum possible height
//    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
//    
    // Give it the media item
    layoutCell.mediaItem = mediaItem;
    
    // Make it adjust the image view and labels
//    [layoutCell layoutSubviews];
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    // The height will be wherever the bottom of the comments label is
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.mediaItem) {
        
        // Before layout, calculate the intrinsic size of the labels (the size they "want" to be), and add 20 to the height for some vertical padding.
        CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
        CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];  // (seems like "find the best size that fits inside this max size".  NOT creating a CGSize with a gigantic maxed out height.  creating one that is it's best intrinsic size while fitting inside the maxSize)
        CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
        
        // as39
//        CGSize likesLabelSize = [self.likesLabel sizeThatFits:maxSize];
//        self.likesLabelHeightConstraint.constant = likesLabelSize.height == 0 ? 0 : likesLabelSize.height + 20;
        
//        self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
        self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height == 0 ? 0 : usernameLabelSize.height + 20;
        
//        self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
        self.commentLabelHeightConstraint.constant = commentLabelSize.height == 0 ? 0 : commentLabelSize.height + 20;
        
//        self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
        if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0) {
            self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
        } else {
            self.imageHeightConstraint.constant = 0;
        }
        
    }
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);
}


- (void) setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState; // this is key, as it will trigger the button to change its look as the mediaItem is toggled
    
    // as39

//    self.likesLabel.text = mediaItem.likesCount;  // this doesn't work directly for some reason.  it's NSNumber.. kind of.  anyway, the below works.
//    self.likesLabel.text = [NSString stringWithFormat:@"%@", mediaItem.likesCount];
    
    // as39 (2)
    NSString *numLikesString = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", mediaItem.likesCount]];
    self.likesLabel.attributedText = [self likesString:numLikesString];
    self.likesLabel.textAlignment = NSTextAlignmentRight;
    
}

- (NSAttributedString *) likesString:(NSString *)numLikesString {
    CGFloat likesFontSize = 12;
    NSString *baseString = numLikesString;
    NSMutableAttributedString *mutableLikesString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName: [lightFont fontWithSize:likesFontSize]}];
    return mutableLikesString;
}

- (NSAttributedString *) usernameAndCaptionString {
    // #1
    CGFloat usernameFontSize = 15;
    
    // #2 - Make a string that says "username caption"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // #3 - Make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    // #4
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;
}


- (NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        // Make an attributed string, with the "username" bold
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}

#pragma mark - Liking

- (void) likePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self];
}

#pragma mark - Image View

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

#pragma mark - UIGestureRecognizerDelegate
// to make sure the tap to zoom on image doesn't fire when the delete swipe option is up (and instead hides the delete button).  DON'T UNDERSTAND   
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}





@end
