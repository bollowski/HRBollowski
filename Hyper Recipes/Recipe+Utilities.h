//
//  Recipe+Utilities.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 13/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "Recipe.h"

@interface Recipe (Utilities)

// Convert the difficulty so it can be used as a segment index
- (int)difficultyAsSegmentIndex;

// Return the url to the image as a NSURLRequest
- (NSURLRequest *)photoUrlRequest;

// Convert bool value to string for favorite
- (NSString *)favoriteAsString;

// Adjust the photo name so it follow server standards
- (NSString *)photoNameForServer;

@end
