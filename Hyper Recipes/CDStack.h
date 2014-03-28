//
//  CDStack.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 11/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CDStack : NSObject

@property(nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL;

@end
