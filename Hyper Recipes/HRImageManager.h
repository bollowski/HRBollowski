//
//  HRImageManager.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 25/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

// Manage image operations

#import <Foundation/Foundation.h>
#import "Recipe.h"
#import "Recipe+LocalAccessors.h"

@interface HRImageManager : NSObject

// Load local image 
- (UIImage *)loadImageForRecipe:(Recipe *)recipe;

// Store image locally
- (NSString *)storeImage:(UIImage *)image;

// Delete local image
- (void)deleteImageWithPath:(NSString *)path;

@end
