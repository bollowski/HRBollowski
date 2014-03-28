//
//  Recipe.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 28/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

// TODO: Add separete entity that manage the state of a recipe (shouldbeuploaded, uploading, removefromserver), not prioritized.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recipe : NSManagedObject

@property (nonatomic, retain) NSString * changedateonserver;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * instructions;
@property (nonatomic, retain) NSString * localphotopath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * objectidonserver;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * removefromserver;
@property (nonatomic, retain) NSNumber * uploading;
@property (nonatomic, retain) NSNumber * shouldbeuploaded;

@end
