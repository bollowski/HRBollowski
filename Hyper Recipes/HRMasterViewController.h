//
//  HRMasterViewController.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 06/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "HRAddAndEditRecipeViewController.h"
#import "HRDetailViewController.h"
#import "Recipe+LocalAccessors.h"
#import "Recipe+RemoteAccessors.h"
#import "FetchedResultsControllerDataSource.h"
#import "HRRecipeCell.h"
#import "HRRecipeServerManager.h"
#import "HRImageManager.h"

@class HRDetailViewController;

@interface HRMasterViewController : UICollectionViewController

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) HRRecipeServerManager *recipeServerManager;

- (IBAction)refresh:(id)sender;

- (void)configureCell:(UICollectionView *)aCell withObject:(Recipe *)recipe;

@end
