//
//  HRRecipeCell.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 20/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRRecipeCell : UICollectionViewCell

@property(weak, nonatomic) IBOutlet UILabel *missingPhotoLabel;
@property(weak, nonatomic) IBOutlet UIImageView *imageView;
@property(weak, nonatomic) IBOutlet UILabel *name;
@property(weak, nonatomic) IBOutlet UIImageView *favoritePin;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
