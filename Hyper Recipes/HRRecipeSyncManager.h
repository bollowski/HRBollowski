//
//  HRRecipeSyncManager.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 23/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

// Manage Recipes sync with server

#import <Foundation/Foundation.h>
#import "SyncStatus.h"
#import "Recipe+LocalAccessors.h"
#import "Recipe+RemoteAccessors.h"

@interface HRRecipeSyncManager : NSObject
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

// Allow complete sync between remote and local data
- (void)syncData;

// Push a new recipe to server
- (void)pushToServerWhenNoServerObjectId;

// Update a recipe on server
- (void)pushToServerWithRecipe:(Recipe *)recipe;

// Remove recipe from server
- (void)pushRemoveFromServerWithRecipe:(Recipe *)recipe;

// Mark/Unmark recipe as favorite
- (void)pushUpdateFavoriteToServerWithRecipe:(Recipe *)recipe;

@end
