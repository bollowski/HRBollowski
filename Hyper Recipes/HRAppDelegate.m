//
//  HRAppDelegate.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 06/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

/**
 - The app try to be as good offline as online
 - The app sync completly in background and shouldn't effect the user
 - The app works on iPhone and iPad
 - Images are only applied for iPhone 4 or higher as this app run on iOS 7+
**/

#import "HRAppDelegate.h"

@implementation HRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configure Lumberjack
    // Send to Console.app
    [DDLog addLogger:[DDASLLogger sharedInstance]];

    // Send to xcode console
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // Init stack
    self.stack = [[CDStack alloc] initWithStoreURL:self.storeURL modelURL:self.modelURL];

    // Set up cache
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:15 * 1024 * 1024 diskCapacity:60 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    // Show indicator on network activity
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // Override point for customization after application launch.
    UINavigationController *navigationController = (UINavigationController *) self.window.rootViewController;
    HRMasterViewController *recipeListViewController = (HRMasterViewController *) navigationController.topViewController;
    recipeListViewController.managedObjectContext = self.stack.managedObjectContext;
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //Core Data: Store the managed object context
    [self saveContext];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //Core Data: Store the managed object context
    [self saveContext];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // Clear cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)saveContext {
    NSError *error = nil;

    if (![self.stack.managedObjectContext save:&error])
    DDLogError(@"HRAppDelegate - saveContext - Core Data Error saving in Appdelegat: %@", [error localizedDescription]);
}

- (NSURL *)storeURL {
    NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                       inDomain:NSUserDomainMask
                                                              appropriateForURL:nil
                                                                         create:YES
                                                                          error:NULL];
    return [documentsDirectory URLByAppendingPathComponent:@"HyperRecipe.sqlite"];
}

- (NSURL *)modelURL {
    return [[NSBundle mainBundle] URLForResource:@"HyperRecipe" withExtension:@"momd"];
}

@end
