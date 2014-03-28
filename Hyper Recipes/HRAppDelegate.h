//
//  HRAppDelegate.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 06/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "CDStack.h"
#import "HRMasterViewController.h"

@interface HRAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) CDStack *stack;

@end
