//
//  HRFetchedResultsController.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 19/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

// Provide the UICOllectionview with data

#import "FetchedResultsControllerDataSource.h"


@interface FetchedResultsControllerDataSource ()

- (BOOL)shouldReloadCollectionView;


@property(strong, nonatomic) UICollectionView *collectionView;
@property(strong, nonatomic) NSMutableArray *objectChanges;
@property(strong, nonatomic) NSMutableArray *sectionChanges;

@end

@implementation FetchedResultsControllerDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;

        self.sectionChanges = [[NSMutableArray alloc] init];
        self.objectChanges = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo;
    sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    id cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];

    [self.delegate configureCell:cell withObject:object];

    return cell;
}

#pragma mark - NSFetchedResultsController

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [NSMutableDictionary new];

    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }

    [self.objectChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [NSMutableDictionary new];

    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }

    [self.sectionChanges addObject:change];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([self.sectionChanges count] > 0) {
        [self.collectionView performBatchUpdates:^{

            for (NSDictionary *change in self.sectionChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type) {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeMove:
                            break;
                    }
                }];
            }
        }                             completion:nil];
    }

    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0) {
        if ([self shouldReloadCollectionView] || self.collectionView.window == nil) {
            [self.collectionView reloadData];
        } else {
            [self.collectionView performBatchUpdates:^{

                for (NSDictionary *change in _objectChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            }                             completion:nil];
        }
    }

    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionView {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;

            switch (type) {
                case NSFetchedResultsChangeInsert:
                    shouldReload = [self.collectionView numberOfItemsInSection:indexPath.section] == 0;
                    break;
                case NSFetchedResultsChangeDelete:
                    shouldReload = [self.collectionView numberOfItemsInSection:indexPath.section] == 1;
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }

    return shouldReload;
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController.delegate = nil;
        _fetchedResultsController = fetchedResultsController;

        if (_fetchedResultsController) {
            _fetchedResultsController.delegate = self;
            [self performFetch];
        }
        else {
            [self.collectionView reloadData];
        }
    }
}

- (id)selectedItem {
    NSIndexPath *path = [self.collectionView.indexPathsForSelectedItems objectAtIndex:0];
    return path ? [self.fetchedResultsController objectAtIndexPath:path] : nil;
}

- (void)performFetch {
    if (self.fetchedResultsController) {
        NSError *error;

        if (![self.fetchedResultsController performFetch:&error])
        DDLogError(@"FetchedResultsControllerDataSource - performFetch - Error performing fetch: %@", [error localizedDescription]);
    }

    [self.collectionView reloadData];
}

@end
