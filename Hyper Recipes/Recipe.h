//
//  Recipe.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 28/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SyncStatus.h"


@interface Recipe : SyncStatus

@property(nonatomic, retain) NSString *changedateonserver;
@property(nonatomic, retain) NSString *desc;
@property(nonatomic, retain) NSNumber *difficulty;
@property(nonatomic, retain) NSNumber *favorite;
@property(nonatomic, retain) NSString *instructions;
@property(nonatomic, retain) NSString *localphotopath;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSNumber *objectidonserver;
@property(nonatomic, retain) NSString *photo;

@end
