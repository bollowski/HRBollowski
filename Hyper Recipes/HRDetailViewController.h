//
//  HRDetailViewController.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 06/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "HRRecipeSyncManager.h"
#import "HRImageManager.h"
#import "Recipe.h"
#import "HRAddAndEditRecipeViewController.h"
#import "Recipe+Utilities.h"

@interface HRDetailViewController : UIViewController

- (IBAction)favorite:(id)sender;

@property(weak, nonatomic) IBOutlet UILabel *missingPhotoLabel;
@property(weak, nonatomic) IBOutlet UISegmentedControl *difficulty;
@property(weak, nonatomic) IBOutlet UIImageView *deliciousImage;
@property(weak, nonatomic) IBOutlet UILabel *recipeName;
@property(weak, nonatomic) IBOutlet UILabel *description;
@property(weak, nonatomic) IBOutlet UILabel *instructions;
@property(weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property(nonatomic, strong) Recipe *recipe;

@end
