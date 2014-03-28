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

+ (void)loadAllOnResult:(RecipeArrayBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

- (void)createInstanceOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

- (void)markRecipeAsFavoriteOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

- (void)saveOnResult:(RecipeObjectIdBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

- (void)deleteFromServerOnResult:(RecipeObjectBlock)resultBlock onError:(RecipeErrorBlock)errorBlock;

- (void)recipeIsUploadingToServer;

- (void)recipeIsNotUploadingToServer;

@end
