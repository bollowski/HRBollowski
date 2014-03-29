//
//  HRRecipeManager.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 23/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//


#import "HRRecipeSyncManager.h"

@interface HRRecipeSyncManager ()

- (void)removeLocalRecipeIfNotInArray:(NSArray *)result;

- (void)removeRecipesOnServer;

- (void)pushNotSyncedToServer;

- (void)updateWithResult:(NSArray *)result;

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation HRRecipeSyncManager

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        self.managedObjectContext = context;
    }
    return self;
}

// This method ensure that the data is in complete sync
- (void)syncData {
    [Recipe loadAllOnResult:^(NSArray *result) {

        [self updateWithResult:result]; // Update local recipes if needed
        [Recipe saveInManagedObjectContext:self.managedObjectContext];// Save context so the collection view is updated and the user see the changes
        [self pushNotSyncedToServer]; // Upload edited recipes that have not been synced
        [self pushToServerWhenNoServerObjectId]; // Upload recipes that have not been uploaded
        [self removeLocalRecipeIfNotInArray:result]; // Remove recipes that have been deleted from the server while the app was offline
        [self removeRecipesOnServer]; // Remove recipes from server which was deleted locally while offline
        
    }               onError:^(NSError *error) {
        DDLogWarn(@"HRRecipeServerManager - syncData - Error while loading recipes from server: %@", [error localizedDescription]);
    }];
}

- (void)updateWithResult:(NSArray *)result {
    for (NSDictionary *dic in result) {
        // Try to update/add Recipe if needed
        [Recipe insertOrUpdateRecipeWithServerObjectId:[dic objectForKey:@"id"]
                                                  name:[dic objectForKey:@"name"]
                                           description:[dic objectForKey:@"description"]
                                          instructions:[dic objectForKey:@"instructions"]
                                              favorite:[dic objectForKey:@"favorite"]
                                            difficulty:@([[dic objectForKey:@"difficulty"] intValue])
                                              photoUrl:[[dic objectForKey:@"photo"] objectForKey:@"url"]
                                           changedDate:[dic objectForKey:@"updated_at"]
                                inManagedObjectContext:self.managedObjectContext];
    }
}

- (void)removeLocalRecipeIfNotInArray:(NSArray *)result {
    NSMutableDictionary *allServerObjectID = [[NSMutableDictionary alloc] init];

    for (NSDictionary *dic in result) {
        [allServerObjectID setObject:dic forKey:[dic objectForKey:@"id"]];
    }

    for (Recipe *recipe in [Recipe fetchAllInManagedObjectContext:self.managedObjectContext]) {
        if (recipe.objectidonserver != [NSNumber numberWithInt:0] && ![allServerObjectID objectForKey:recipe.objectidonserver]) {
            [recipe delete];
        }
    }
}

- (void)pushNotSyncedToServer {
    // Should only push a recipe to server if it full fill the criteria: pushtoserver == '' AND uploading == NO AND removefromserver == NO
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pushtoserver == YES AND uploading == NO AND removefromserver == NO"];

    NSArray *shouldBePushed = [Recipe fetchAllUsingPredicate:predicate
                                                     Context:self.managedObjectContext];

    for (Recipe *recipe in shouldBePushed) {
        [self pushToServerWithRecipe:recipe];
    }
}

- (void)pushToServerWhenNoServerObjectId {
    // Should only push a recipe to server if it full fill the criteria: objectidonserver == '' AND uploading == NO AND removefromserver == NO
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pushtoserver == YES AND uploading == NO AND removefromserver == NO"];

    NSArray *shouldBePushed = [Recipe fetchAllUsingPredicate:predicate
                                                     Context:self.managedObjectContext];

    for (Recipe *recipe in shouldBePushed) {
        [self pushToServerWithRecipe:recipe];
    }
}

- (void)pushToServerWithRecipe:(Recipe *)recipe {
    if (![recipe.uploading boolValue]) {
        __weak Recipe *weakRecipe = recipe;

        if ([recipe.objectidonserver intValue] != 0) {
            // We are updating an existing recipe on the server
            [recipe saveOnResult:^(NSNumber *serverObjectId) {
                // Mark the recipe as synced
                [weakRecipe setPushtoserver:[NSNumber numberWithBool:NO ]];
                [weakRecipe save];
            }            onError:^(NSError *error) {
                DDLogWarn(@"HRRecipeManager - pushToServerWithRecipe - failed saveOnResult: %@", [error localizedDescription]);
            }];
        } else {
            // We are adding a recipe to the server
            [recipe createInstanceOnResult:^(NSNumber *serverObjectId) {
                [weakRecipe setObjectidonserver:serverObjectId];
                [weakRecipe setPushtoserver:[NSNumber numberWithBool:NO ]];
                [weakRecipe save];
            }                      onError:^(NSError *error) {
                DDLogWarn(@"HRRecipeManager - pushToServerWithRecipe - failed createInstanceOnResult: %@", [error localizedDescription]);
            }];
        }
    }
}

- (void)pushUpdateFavoriteToServerWithRecipe:(Recipe *)recipe {
    [recipe markRecipeAsFavoriteOnResult:^(NSNumber *serverObjectId) {
        DDLogVerbose(@"markRecipeAsFavoriteOnResult result: %@", serverObjectId);
    }
                                 onError:^(NSError *error) {
                                     DDLogWarn(@"HRRecipeManager - pushUpdateFavoriteToServerWithRecipe - failed markRecipeAsFavoriteOnResult: %@", [error localizedDescription]);
                                 }];
}

- (void)removeRecipesOnServer {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"removefromserver == YES"];

    NSArray *shoudRemoved = [Recipe fetchAllUsingPredicate:predicate
                                                   Context:self.managedObjectContext];

    for (Recipe *recipe in shoudRemoved)
        [self pushRemoveFromServerWithRecipe:recipe];
}

- (void)pushRemoveFromServerWithRecipe:(Recipe *)recipe {
    [recipe deleteFromServerOnResult:^(Recipe *rec) {
        [rec delete];
    }                        onError:^(NSError *error) {
        DDLogWarn(@"HRRecipeServerManager - pushRemoveFromServerWithObjectId - failed deleteOnResult: %@", [error localizedDescription]);
    }];
}



@end
