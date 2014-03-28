//
//  HRAddAndEditRecipeViewController.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 12/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "HRAddAndEditRecipeViewController.h"

@interface HRAddAndEditRecipeViewController ()

- (void)configureView;

- (NSNumber *)difficultyFromSelectedSegmentIndex;

- (void)deleteRecipe;

- (void)fillOutTextViewForDescriptionAndInstructions;

- (void)storeRecipe;

@property(nonatomic, strong) NSManagedObjectID *objectId;
@property(nonatomic, strong) NSString *photoUrl;
@property(nonatomic, strong) NSString *localPhotoUrl;
@property(nonatomic, strong) NSString *changedDate;
@property(nonatomic) BOOL unwind;
@property(nonatomic, strong) HRImageManager *imageManager;

@end

@implementation HRAddAndEditRecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageManager = [[HRImageManager alloc] init];

    [self fillOutTextViewForDescriptionAndInstructions];

    //If recipe exist then we are in "edit mode"
    if (self.recipe) {
        [self configureView];
    } else {
        self.deleteButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self unRegisterFromKeyboardNotifications];
}

- (void)configureView {
    self.deleteButton.hidden = NO;

    // The image url and the objectId, on the server, should not be exposed to the user.
    self.objectId = self.recipe.objectID;
    self.photoUrl = self.recipe.photo;
    self.localPhotoUrl = self.recipe.localphotopath;
    self.changedDate = self.recipe.changedateonserver;

    UIImage *img = [self.imageManager loadImageForRecipe:self.recipe];

    if (img) {
        [self.photo setImage:img];
    } else if ([self.photoUrl length]) {
        [self.photo.imageResponseSerializer setAcceptableContentTypes:[NSSet setWithObjects:(@"photo/jpeg"), (@"image/jpeg"), nil]];
        [self.photo setImageWithURLRequest:self.recipe.photoUrlRequest
                          placeholderImage:nil
                                   success:nil
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // If download fail make show text
                                       DDLogWarn(@"HRAddAndEditRecipeViewController - configureView - Failed to download image: %@", [error localizedDescription]);
                                   }];
    }

    self.managedObjectContext = self.recipe.managedObjectContext;
    self.recipeName.text = self.recipe.name;

    [self.difficultySegment setSelectedSegmentIndex:self.recipe.difficultyAsSegmentIndex];
}

- (void)fillOutTextViewForDescriptionAndInstructions {
    if ([self.recipe.desc length])
        self.recipeDescription.text = self.recipe.desc;
    else
        self.recipeDescription.text = NSLocalizedString(@"Tap the pen and paper icon to write a description of the recipe.", nil);

    if ([self.recipe.instructions length])
        self.recipeInstruction.text = self.recipe.instructions;
    else
        self.recipeInstruction.text = NSLocalizedString(@"Tap the pen and paper icon to write instructions for the recipe.", nil);
}

- (NSNumber *)difficultyFromSelectedSegmentIndex {
    return [NSNumber numberWithLong:self.difficultySegment.selectedSegmentIndex + 1];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)delete:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are about to delete the recipe!", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:NSLocalizedString(@"Delete", nil)
                                                    otherButtonTitles:nil, nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (IBAction)save:(id)sender {

    if ([self.recipeName.text length]) {
        [self storeRecipe];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
                                           message:NSLocalizedString(@"You need to give the recipe a name.", nil)
                                          delegate:nil
                                 cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                 otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)storeRecipe {
    NSString *descriptionToSave;
    NSString *instructionsToSave;

    if ([self.recipeDescription.text isEqualToString:NSLocalizedString(@"Tap the pen and paper icon to write a description of the recipe.", nil)])
        descriptionToSave = @"";
    else
        descriptionToSave = self.recipeDescription.text;

    if ([self.recipeInstruction.text isEqualToString:NSLocalizedString(@"Tap the pen and paper icon to write instructions for the recipe.", nil)])
        instructionsToSave = @"";
    else
        instructionsToSave = self.recipeInstruction.text;

    // Local image has been change so we should remove the ref to the remote one
    if([self.localPhotoUrl length])
        self.photoUrl = @"";
    
    Recipe *recp = [Recipe insertOrUpdateRecipeWithObjectId:self.objectId
                                                       name:self.recipeName.text
                                                description:descriptionToSave
                                               instructions:instructionsToSave
                                                   favorite:[NSNumber numberWithBool:NO]
                                                 difficulty:[self difficultyFromSelectedSegmentIndex]
                                                   photoUrl:self.photoUrl
                                              localPhotoUrl:self.localPhotoUrl
                                                changedDate:self.changedDate
                                     inManagedObjectContext:self.managedObjectContext];
    [recp save];

    HRRecipeServerManager *recipeServerManager = [[HRRecipeServerManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    [recipeServerManager pushToServerWithRecipe:recp];
}

- (void)deleteRecipe {
    //  Delete stored image on phone
    if ([self.recipe.localphotopath length])
        [self.imageManager deleteImageWithPath:self.recipe.localphotopath];
    
    if ([self.recipe.objectidonserver intValue] != 0) {
        // Inform that on next sync this recipe should be deleted
        self.recipe.removefromserver = [NSNumber numberWithBool:YES];
        [self.recipe save];
    }
    else {
        // Recipe has not yet been uploaded to the server so we can just delete it
        [self.recipe delete];
        [Recipe saveInManagedObjectContext:self.managedObjectContext];
    }
    
    // Go back to main view
    self.unwind = YES;
    [self performSegueWithIdentifier:@"unwindToRootVC" sender:self];
}

#pragma mark - Photo
- (IBAction)photo:(id)sender {
    UIActionSheet *photoSourcePicker = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose from Library", nil), nil];
    photoSourcePicker.tag = 0;

    [photoSourcePicker showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];

    [self.photo setImage:image];
    self.localPhotoUrl = [self.imageManager storeImage:image];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        switch (buttonIndex) {
            case 0: {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.allowsEditing = YES;
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                    imagePicker.delegate = self;

                    [self presentViewController:imagePicker
                                       animated:YES
                                     completion:nil];
                }
                else {
                    UIAlertView *alert;
                    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                       message:NSLocalizedString(@"This device doesn't have a camera.", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                             otherButtonTitles:nil];
                    [alert show];
                }
                break;
            }
            case 1: {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePicker.allowsEditing = YES;
                    imagePicker.delegate = self;

                    [self presentViewController:imagePicker
                                       animated:YES
                                     completion:nil];
                } else {
                    UIAlertView *alert;
                    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                       message:NSLocalizedString(@"This device doesn't have a photo library.", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                             otherButtonTitles:nil];
                    [alert show];
                }
                break;
            }
            default:
                break;
        }
    } else if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0: {
                [self deleteRecipe];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Textfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)registerForKeyboardNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)unRegisterFromKeyboardNotifications {

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];

    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint buttonOrigin = self.recipeName.frame.origin;
    CGFloat buttonHeight = self.recipeName.frame.size.height * 4;
    CGRect visibleRect = self.view.frame;

    visibleRect.size.height -= keyboardSize.height;

    if (!CGRectContainsPoint(visibleRect, buttonOrigin)) {
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"unwindToRootVC"]) if (!self.unwind)
        return NO;
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"composeDescription"]) {
        NSString *descriptionDefaultString = NSLocalizedString(@"Tap the pen and paper icon to write a description of the recipe.", nil);

        HRComposeViewController *composeViewController = segue.destinationViewController;
        composeViewController.composeType = @"description";

        if (![self.recipeDescription.text isEqualToString:descriptionDefaultString] &&
                ![self.recipeDescription.text isEqualToString:self.recipe.desc]) {
            composeViewController.text = self.recipeDescription.text;
        } else if ([self.recipe.desc length]) {
            composeViewController.text = self.recipe.desc;
        } else {
            composeViewController.text = @"";
        }

    } else if ([[segue identifier] isEqualToString:@"composeInstructions"]) {
        NSString *infoDefaultString = NSLocalizedString(@"Tap the pen and paper icon to write instructions for the recipe.", nil);

        HRComposeViewController *composeViewController = segue.destinationViewController;
        composeViewController.composeType = @"instructions";

        if (![self.recipeInstruction.text isEqualToString:infoDefaultString] &&
                ![self.recipeInstruction.text isEqualToString:self.recipe.instructions]) {
            composeViewController.text = self.recipeInstruction.text;
        } else if ([self.recipe.instructions length]) {
            composeViewController.text = self.recipe.instructions;
        } else {
            composeViewController.text = @"";
        }
    }
}

- (IBAction)unwindToAddAndEditRecipeVC:(UIStoryboardSegue *)segue {
    // Nothing needed here.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end