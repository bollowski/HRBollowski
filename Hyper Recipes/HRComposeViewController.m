//
//  HRWriteTextViewController.m
//  Hyper Recipes
//
//  Created by Mikael Bolle on 22/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import "HRComposeViewController.h"

@interface HRComposeViewController ()

- (void)registerForKeyboardNotifications;

@property(nonatomic, strong) NSTimer *markerVisibilityTimer;
@property(nonatomic) CGRect oldRectForMarker;

@end

@implementation HRComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    self.textView.text = self.text;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

//Force portrait orientation
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"unwindToAddAndEditRecipeVC"]) {
        HRAddAndEditRecipeViewController *addRecipeViewController = segue.destinationViewController;
        if ([self.composeType isEqualToString:@"instructions"]) {
            addRecipeViewController.recipeInstruction.text = self.textView.text;
        } else {
            addRecipeViewController.recipeDescription.text = self.textView.text;
        }
    }
}

- (void)scrollMarkerToVisible {
    //Place of marker/caret
    CGRect rectForMarker = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];

    //If there is no change do nothing
    if (CGRectEqualToRect(rectForMarker, self.oldRectForMarker)) {
        return;
    }

    self.oldRectForMarker = rectForMarker;

    CGRect visibleViewRect = self.textView.bounds;
    visibleViewRect.size.height -= (self.textView.contentInset.top + self.textView.contentInset.bottom);
    visibleViewRect.origin.y = self.textView.contentOffset.y;

    //Sroll only if the marker/caret falls outside of the visible rect.
    if (!CGRectContainsRect(visibleViewRect, rectForMarker)) {
        CGPoint newOffset = self.textView.contentOffset;

        newOffset.y = MAX((rectForMarker.origin.y + rectForMarker.size.height) - visibleViewRect.size.height + 5, 0);

        [self.textView setContentOffset:newOffset animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    //Adjust inset between the content view and the enclosing text view
    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom += [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.textView.contentInset = insets;

    insets = self.textView.scrollIndicatorInsets;
    insets.bottom += [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.textView.scrollIndicatorInsets = insets;
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    //Adjust inset between the content view and the enclosing text view
    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    self.textView.contentInset = insets;

    insets = self.textView.scrollIndicatorInsets;
    insets.bottom -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    self.textView.scrollIndicatorInsets = insets;
}

#pragma mark - TextViewFrame

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.oldRectForMarker = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];

    //Init monitor of x & y changes for marker/caret
    self.markerVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                  target:self
                                                                selector:@selector(scrollMarkerToVisible)
                                                                userInfo:nil
                                                                 repeats:YES];
    [self scrollMarkerToVisible];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //Remove timer
    [self.markerVisibilityTimer invalidate];
    self.markerVisibilityTimer = nil;
}
@end
