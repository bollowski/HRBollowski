//
//  HRWriteTextViewController.h
//  Hyper Recipes
//
//  Created by Mikael Bolle on 22/03/14.
//  Copyright (c) 2014 Mikael Bolle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRAddAndEditRecipeViewController.h"

@interface HRComposeViewController : UIViewController <UITextViewDelegate>

- (IBAction)cancel:(id)sender;

@property(weak, nonatomic) IBOutlet UITextView *textView;

@property(nonatomic, strong) NSString *composeType;
@property(nonatomic, strong) NSString *text;

@end
