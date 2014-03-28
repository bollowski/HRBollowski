//
//  HRFetchedResultsController.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 19/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSFetchedResultsController;

@protocol FetchedResultsControllerDataSourceDelegate

- (void)configureCell:(id)cell withObject:(id)object;

@end

@interface FetchedResultsControllerDataSource : NSObject <UICollectionViewDataSource, NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, weak) id <FetchedResultsControllerDataSourceDelegate> delegate;
@property(nonatomic, copy) NSString *reuseIdentifier;

- (id)initWithCollectionView:(UICollectionView *)collectionView;

- (id)selectedItem;

- (void)performFetch;

@end
