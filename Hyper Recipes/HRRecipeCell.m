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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetCell];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)resetCell {
    [self.missingPhotoLabel setHidden:YES];
    [self.imageView setHidden: YES];
    [self.imageView setImage:nil];
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}

// Fix the cell so that it shows image "status" correctly
- (void)configureCellWithFoundImage:(BOOL)display {
    if (display) {
        [self.imageView setHidden:NO];
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        [self.missingPhotoLabel setHidden:YES];
    } else {
        [self.imageView setImage:nil];
        [self.imageView setHidden:YES];
        [self.activityIndicator setHidden:YES];
        [self.activityIndicator stopAnimating];
        [self.missingPhotoLabel setHidden:NO];
    }
}
@end
