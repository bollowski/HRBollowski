//
//  HRAPIManager.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 23/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@interface HRAPIManager : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (NSString *)baseURLAsString;

@end
