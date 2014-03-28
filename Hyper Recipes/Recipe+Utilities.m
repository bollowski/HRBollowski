//
//  Recipe+Utilities.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 13/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "Recipe+Utilities.h"

@implementation Recipe (Utilities)

// Manage difficulty as a UISegment
- (int)difficultyAsSegmentIndex {
    return [self.difficulty intValue] - 1;
}

- (NSString *)favoriteAsString {
    if ([self.favorite boolValue])
        return @"true";
    else
        return @"false";
}

- (NSURLRequest *)photoUrlRequest {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:self.photo]];
}

// Generate a nice image name for the server
- (NSString *)photoNameForServer {
    return [[self.name stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAppendingString:@".jpg"];
}

@end
