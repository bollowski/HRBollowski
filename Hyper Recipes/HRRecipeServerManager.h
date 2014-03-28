//
//  HRRecipeManager.h
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

@interface HRRecipeServerManager : NSObject
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)syncData;

- (void)pushToServerWhenNoServerObjectId;

- (void)pushToServerWithRecipe:(Recipe *)recipe;

- (void)pushRemoveFromServerWithRecipe:(Recipe *)recipe;

- (void)pushUpdateFavoriteToServerWithRecipe:(Recipe *)recipe;

@end
