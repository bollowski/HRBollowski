//
//  SyncStatus.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 28/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncStatus : NSManagedObject

@property(nonatomic, retain) NSNumber *uploading;
@property(nonatomic, retain) NSNumber *pushtoserver;
@property(nonatomic, retain) NSNumber *removefromserver;

@end
