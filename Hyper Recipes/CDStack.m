//
//  CDStack.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 11/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "CDStack.h"

// TODO: decide whether to use background thread for core data
@interface CDStack ()

@property(nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) NSURL *modelURL;
@property(nonatomic, strong) NSURL *storeURL;

- (void)setupManagedObjectContext;

- (NSManagedObjectModel *)managedObjectModel;

@end

@implementation CDStack

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL {
    self = [super init];
    if (self) {
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        [self setupManagedObjectContext];
    }
    return self;
}

- (void)setupManagedObjectContext {
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    NSError *error;

    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:self.storeURL
                                                                             options:nil
                                                                               error:&error];
    if (error) {
        DDLogError(@"CDStack - setupManagedObjectContext - Core Data error: %@", [error localizedDescription]);
    }
}

- (NSManagedObjectModel *)managedObjectModel {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}


@end
