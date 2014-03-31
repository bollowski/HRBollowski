//
//  HRRecipeCell.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 20/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "HRRecipeCell.h"

@interface HRRecipeCell ()

- (void)resetCell;

@end

@implementation HRRecipeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self resetCell];
}

- (void)resetCell
{
    self.missingPhotoLabel.hidden = YES;
    self.imageView.hidden         = YES;
    self.imageView.image          = nil;
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

// Fix the cell so that it shows image "status" correctly
- (void)configureCellWithFoundImage:(BOOL)display
{
    if (display) {
        self.imageView.hidden         = NO;
        self.activityIndicator.hidden = YES;
        self.missingPhotoLabel.hidden = YES;
        [self.activityIndicator stopAnimating];
    } else {
        self.imageView.image          = nil;
        self.imageView.hidden         = YES;
        self.activityIndicator.hidden = YES;
        self.missingPhotoLabel.hidden = NO;
        [self.activityIndicator stopAnimating];
    }
}
@end
