//
//  HRAPIManager.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 23/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "HRAPIManager.h"

static NSString *const APIBaseURLString = @"http://hyper-recipes.herokuapp.com";

@implementation HRAPIManager

+ (instancetype)sharedClient {
    static HRAPIManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HRAPIManager alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURLString]];
    });

    return _sharedClient;
}

- (NSString *)baseURLAsString {
    return APIBaseURLString;
}

@end
