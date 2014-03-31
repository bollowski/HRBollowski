//
//  Recipe+LocalAccessors.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 11/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "Recipe+LocalAccessors.h"

@implementation Recipe (LocalAccessors)

+ (NSString *)entityName
{
    return @"Recipe";
}

+ (NSString *)cacheName
{
    return @"RecipeCache";
}

// Store or update a recipe in Core Data
+ (Recipe *)insertOrUpdateRecipeWithObjectId:(NSManagedObjectID *)objectId
                                        name:(NSString *)name
                                 description:(NSString *)description
                                instructions:(NSString *)instructions
                                    favorite:(NSNumber *)favorite
                                  difficulty:(NSNumber *)difficulty
                                    photoUrl:(NSString *)photoUrl
                               localPhotoUrl:(NSString *)localPhotoUrl
                                 changedDate:(NSString *)changedDate
                      inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Recipe *recipe;

    if (objectId) {
        //Find object that should be updated
        recipe = (id) [managedObjectContext objectWithID:objectId];
    }

    if (!recipe) {
        recipe = [NSEntityDescription insertNewObjectForEntityForName:self.entityName
                                               inManagedObjectContext:managedObjectContext];
    }

    recipe.name = name;
    recipe.desc = description;
    recipe.instructions = instructions;
    recipe.favorite = favorite;
    recipe.difficulty = difficulty;
    recipe.photo = photoUrl;
    recipe.localphotopath = localPhotoUrl;
    recipe.changedateonserver = changedDate;
    recipe.pushtoserver = @YES;

    return recipe;
}

// Store or update a recipe in Core Data if we are given a serverObjectId (Recipe created on another device)
+ (Recipe *)insertOrUpdateRecipeWithServerObjectId:(NSNumber *)serverObjectId
                                              name:(NSString *)name
                                       description:(NSString *)description
                                      instructions:(NSString *)instructions
                                          favorite:(NSNumber *)favorite
                                        difficulty:(NSNumber *)difficulty
                                          photoUrl:(NSString *)photoUrl
                                       changedDate:(NSString *)changedDate
                            inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // Find object that should be updated
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectidonserver == %@", serverObjectId];
    NSArray *result = [Recipe fetchAllUsingPredicate:predicate Context:managedObjectContext];
    Recipe *recipe;

    if ([result count] > 1) {
        DDLogWarn(@"Recipe+LocalAccessors - insertOrUpdateRecipeWithServerObjectId - result should only return 1 object. [result count] : %tu", [result count]);
    }

    recipe = [result lastObject];

    if (!recipe) {
        recipe = [NSEntityDescription insertNewObjectForEntityForName:self.entityName
                                               inManagedObjectContext:managedObjectContext];
    }

    if (![recipe.changedateonserver isEqualToString:changedDate]) {
        recipe.name = name;
        recipe.desc = description           != (NSString *) [NSNull null] ? description : @"";
        recipe.instructions = instructions  != (NSString *) [NSNull null] ? instructions : @"";
        recipe.favorite = favorite          != (NSNumber *) [NSNull null] ? favorite : @NO;
        recipe.photo = photoUrl             != (NSString *) [NSNull null] ? photoUrl : @"";
        recipe.difficulty = difficulty;
        recipe.objectidonserver = serverObjectId;
        recipe.changedateonserver = changedDate;
        recipe.pushtoserver = @YES;
    }
    return recipe;
}

// Get a dump of the data
+ (NSArray *)fetchAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:self.entityName
                                        inManagedObjectContext:managedObjectContext]];

    [fetchRequest setPredicate:nil];
    [fetchRequest setIncludesSubentities:YES];

    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest
                                                          error:&error];

    if (error) {
        DDLogWarn(@"Recipe+LocalAccessors - fetchAllInManagedObjectContext - failed  to find recipe upron to update:: %@", error.localizedDescription);
    }

    return result;
}

+ (NSArray *)fetchAllUsingPredicate:(NSPredicate *)predicate
                            Context:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:self.entityName
                                        inManagedObjectContext:managedObjectContext]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesSubentities:YES];

    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest
                                                          error:&error];

    if (error) {
        DDLogWarn(@"Recipe+LocalAccessors - fetchAllUsingPredicate - failed to find recipe: %@", error.localizedDescription);
    }

    return result;
}

+ (NSFetchedResultsController *)fetchedResultsControllerWitSort:(NSSortDescriptor *)sort
                                                        Context:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName
                                              inManagedObjectContext:managedObjectContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"removefromserver == NO"];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:10];

    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:managedObjectContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:[Recipe cacheName]];
}

// Flush cache
+ (void)deleteCache
{
    [NSFetchedResultsController deleteCacheWithName:[Recipe cacheName]];
}

+ (void)saveInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    BOOL success = [managedObjectContext save:&error];
    if (!success) {
        DDLogWarn(@"Recipe+LocalAccessors - saveInManagedObjectContext - failed to update/save recipe: %@:", error.localizedDescription);
    }
}

// Mark/Unmark a recipe as a favorite
- (void)markAsFavorite
{
    self.favorite = @(![self.favorite boolValue]);
}

- (void)save
{
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        DDLogWarn(@"Recipe+LocalAccessors - save - failed to update/save recipe: %@:", error.localizedDescription);
    }
}

- (void)delete
{
    [self.managedObjectContext deleteObject:self];
}

@end
