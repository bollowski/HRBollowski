//
//  HRAddAndEditRecipeViewController.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 12/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Recipe+LocalAccessors.h"
#import "Recipe+Utilities.h"
#import "HRComposeViewController.h"
#import "Recipe+RemoteAccessors.h"
#import "HRRecipeServerManager.h"
#import "HRImageManager.h"

@interface HRAddAndEditRecipeViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

- (IBAction)cancel:(id)sender;

- (IBAction)save:(id)sender;

- (IBAction)delete:(id)sender;

- (IBAction)photo:(id)sender;

@property(weak, nonatomic) IBOutlet UILabel *recipeDescription;
@property(weak, nonatomic) IBOutlet UILabel *recipeInstruction;
@property(weak, nonatomic) IBOutlet UITextField *recipeName;
@property(weak, nonatomic) IBOutlet UIButton *deleteButton;
@property(weak, nonatomic) IBOutlet UISegmentedControl *difficultySegment;
@property(weak, nonatomic) IBOutlet UIImageView *photo;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) Recipe *recipe;

@end
