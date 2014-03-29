//
//  HRMasterViewController.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 06/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "HRMasterViewController.h"

@interface HRMasterViewController () <FetchedResultsControllerDataSourceDelegate, UITextFieldDelegate>

- (void)configureFoundImageForCell:(id)aCell
                           display:(BOOL)display;

@property(nonatomic, strong) FetchedResultsControllerDataSource *fetchedResultsControllerDataSource;
@property(nonatomic, strong) HRImageManager *imageManager;

@end

@implementation HRMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageManager = [[HRImageManager alloc] init];
    self.recipeServerManager = [[HRRecipeSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    [self setupFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    // Sync data with server each time this view appears
    [self.recipeServerManager syncData];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (IBAction)refresh:(id)sender {
    [self.recipeServerManager syncData];
}

- (void)setupFetchedResultsController {
    if (_fetchedResultsController == nil) {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

        self.fetchedResultsController = [Recipe fetchedResultsControllerWitSort:sort
                                                                        Context:self.managedObjectContext];

        self.fetchedResultsControllerDataSource = [[FetchedResultsControllerDataSource alloc] initWithCollectionView:self.collectionView];
    }

    self.fetchedResultsControllerDataSource.fetchedResultsController = _fetchedResultsController;
    self.fetchedResultsControllerDataSource.delegate = self;
    self.fetchedResultsControllerDataSource.reuseIdentifier = @"RecipeCell";
}

- (void)configureCell:(id)aCell withObject:(Recipe *)recipe {
    HRRecipeCell *cell = aCell;

    [cell.favoritePin setHighlighted:[recipe.favorite boolValue]];

    cell.name.text = recipe.name;

    UIImage *img = [self.imageManager loadImageForRecipe:recipe];

    if (img) {
        [cell configureCellWithFoundImage:YES];
        [cell.imageView setImage:img];
    } else if (![recipe.photo length]) {
        [cell configureCellWithFoundImage:NO];
    } else {
        [cell.activityIndicator startAnimating];
        [cell.activityIndicator setHidden:NO];

        // Add support to MIME photo/jpeg which is not standard
        [cell.imageView.imageResponseSerializer setAcceptableContentTypes:[NSSet setWithObjects:(@"photo/jpeg"), (@"image/jpeg"), nil]];

        __weak Recipe *weakRecipe = recipe;
        __weak HRRecipeCell *weakCell = cell;
        // Set the image
        [cell.imageView setImageWithURLRequest:weakRecipe.photoUrlRequest
                              placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           weakCell.imageView.image = image;
                                           [weakCell configureCellWithFoundImage:YES];

                                           // Fade in image
                                           weakCell.imageView.alpha = 0.0;
                                           [UIView animateWithDuration:1.0
                                                            animations:^{
                                                                weakCell.imageView.alpha = 1.0;
                                                            }];
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           // If download fail show info text
                                           if ([error.localizedDescription isEqualToString:@"Request failed: forbidden (403)"]) {
                                               [weakCell configureCellWithFoundImage:NO];
                                               [weakRecipe setPhoto:@""];
                                               [weakRecipe save];
                                           } else {
                                               DDLogVerbose(@"HRMasterViewController - configureCell - Failed to download image with errro: %@ \n Got response: %@", [error localizedDescription], response);
                                           }
                                       }];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showRecipe"]) {
        NSIndexPath *selectedRowIndex = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];

        HRDetailViewController *detailRecipeViewController = segue.destinationViewController;
        detailRecipeViewController.recipe = [_fetchedResultsController objectAtIndexPath:selectedRowIndex];

    } else if ([[segue identifier] isEqualToString:@"addRecipe"]) {
        HRAddAndEditRecipeViewController *addRecipeViewController = segue.destinationViewController;
        addRecipeViewController.managedObjectContext = self.managedObjectContext;
    }
}

- (IBAction)unwindToRootVC:(UIStoryboardSegue *)segue {
    // A recipe has been marked as deleted and we need to flush the cache to make
    // sure that of NSFetchedResultsController to make sure that the collection is fetched again
    [Recipe deleteCache];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
