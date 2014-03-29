//
//  Recipe+LocalAccessors.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 11/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "Recipe.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface Recipe (LocalAccessors)

+ (NSArray *)fetchAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)fetchAllUsingPredicate:(NSPredicate *)predicate
                            Context:(NSManagedObjectContext *)managedObjectContext;

+ (NSFetchedResultsController *)fetchedResultsControllerWitSort:(NSSortDescriptor *)sort
                                                        Context:(NSManagedObjectContext *)managedObjectContext;

// Update or insert an object that has been created local
+ (Recipe *)insertOrUpdateRecipeWithObjectId:(NSManagedObjectID *)objectId
                                        name:(NSString *)name
                                 description:(NSString *)description
                                instructions:(NSString *)instructions
                                    favorite:(NSNumber *)favorite
                                  difficulty:(NSNumber *)difficulty
                                    photoUrl:(NSString *)photoUrl
                               localPhotoUrl:(NSString *)localPhotoUrl
                                 changedDate:(NSString *)changedDate
                      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

// Update or insert an object that has been created remote
+ (Recipe *)insertOrUpdateRecipeWithServerObjectId:(NSNumber *)serverObjectId
                                              name:(NSString *)name
                                       description:(NSString *)description
                                      instructions:(NSString *)instructions
                                          favorite:(NSNumber *)favorite
                                        difficulty:(NSNumber *)difficulty
                                          photoUrl:(NSString *)photoUrl
                                       changedDate:(NSString *)changedDate
                            inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)saveInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

// Flush the cache of NSFetchedResultsController
+ (void)deleteCache;

- (void)markAsFavorite;

- (void)save;

- (void)delete;

@end
