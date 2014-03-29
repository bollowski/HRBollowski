//
//  Recipe+RemoteAccessors.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 11/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "Recipe.h"
#import "HRAPIManager.h"
#import "Recipe+Utilities.h"
#import "HRImageManager.h"

typedef void(^RecipeArrayBlock)(NSArray *results);

typedef void(^RecipeObjectIdBlock)(NSNumber *objectId);

typedef void(^RecipeObjectBlock)(Recipe *recipe);

typedef void(^RecipeErrorBlock)(NSError *error);

@interface Recipe (RemoteAccessors)

// Get all recipes from server
+ (void)loadAllOnResult:(RecipeArrayBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

// Create a recipe on the server
- (void)createInstanceOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

// Mark a recipe as favorite
- (void)markRecipeAsFavoriteOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

// Update a recipe on the server
- (void)saveOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

// Delete recipe from server
- (void)deleteFromServerOnResult:(RecipeObjectBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

// Tag a recipe when it is currently syncing with serverr
- (void)recipeIsUploadingToServer;

// Tag a recipe when sync is complete
- (void)recipeIsNotUploadingToServer;

@end
