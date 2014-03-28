//
//  HRDetailViewController.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 06/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "HRDetailViewController.h"

@interface HRDetailViewController ()

- (void)configureView;

- (void)updateViewRecipe;

- (void)updateFavoriteButton;

- (void)imageForRecipe;

@property(nonatomic, strong) HRImageManager *imageManager;
@property(nonatomic) BOOL hasVisitedModalView;

@end

@implementation HRDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageManager = [[HRImageManager alloc] init];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    if (self.hasVisitedModalView) {
        [self updateViewRecipe];
        self.hasVisitedModalView = NO;
    }
}

- (void)configureView {
    [self imageForRecipe];
    [self updateFavoriteButton];

    self.recipeName.text = self.recipe.name;

    [self.difficulty setSelectedSegmentIndex:self.recipe.difficultyAsSegmentIndex];

    if ([self.recipe.desc length])
        self.description.text = self.recipe.desc;
    else
        self.description.text = NSLocalizedString(@"No description has been written.", nil);

    if ([self.recipe.instructions length])
        self.instructions.text = self.recipe.instructions;
    else
        self.instructions.text = NSLocalizedString(@"No instructions are given, just look at the image and guess.", nil);
}

- (void)imageForRecipe; {
    self.missingPhotoLabel.text = NSLocalizedString(@"This recipe is missing a photo. Cook and Snap!", nil);

    UIImage *img = [self.imageManager loadImageForRecipe:self.recipe];

    if (img) {
        [self.deliciousImage setImage:img];
    } else if (self.recipe.photo) {
        [self.deliciousImage.imageResponseSerializer setAcceptableContentTypes:[NSSet setWithObjects:(@"photo/jpeg"), (@"image/jpeg"), nil]];
        [self.deliciousImage setImageWithURLRequest:self.recipe.photoUrlRequest
                                   placeholderImage:nil
                                            success:nil
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                // If download fail make show text
                                                DDLogWarn(@"HRDetailViewController - imageForRecipe - Failed to download image: %@", [error localizedDescription]);
                                                self.deliciousImage.hidden = YES;
                                                self.missingPhotoLabel.hidden = NO;
                                            }];
    }
}

- (void)updateViewRecipe {
    self.recipe = (id) [self.recipe.managedObjectContext objectWithID:self.recipe.objectID];

    // Only update view if recipe exist, this block null ref when deleting recipes
    if (self.recipe)
        [self configureView];
}

- (void)updateFavoriteButton {
    [self.favoriteButton setSelected:[self.recipe.favorite boolValue]];
}

- (IBAction)favorite:(id)sender {
    [self.recipe markAsFavorite];
    [self.recipe save];

    HRRecipeServerManager *recipeServerManager = [[HRRecipeServerManager alloc] initWithManagedObjectContext:self.recipe.managedObjectContext];
    [recipeServerManager pushUpdateFavoriteToServerWithRecipe:self.recipe];

    [self updateFavoriteButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"editRecipe"]) {
        self.hasVisitedModalView = YES;
        HRAddAndEditRecipeViewController *addRecipeViewController = segue.destinationViewController;
        addRecipeViewController.recipe = self.recipe;
    }
}
@end
