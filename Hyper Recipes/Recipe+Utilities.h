//
//  Recipe+Utilities.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 13/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "Recipe.h"

@interface Recipe (Utilities)

- (int)difficultyAsSegmentIndex;

- (NSURLRequest *)photoUrlRequest;

- (NSString *)favoriteAsString;

- (NSString *)photoNameForServer;

@end
