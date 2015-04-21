//
//  EnrollViewController.h
//  NDFace
//
//  Created by Abe on 3/10/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnrollViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    UIImagePickerController *picker;
    //UIImagePickerController *picker2;
    UIImage *image;
    //IBOutlet UIImageView *imageView;
    BOOL didSetImage;                   // flag to determine if picture has been chosen
    BOOL aFlag_CanContinue;     // flag to determine if 

    UIButton *theButton; // which image button was pressed to take an image?

    // User Edit Fields
    
    IBOutlet UITextField *firstNameText;
    IBOutlet UITextField *lastNameText;
    IBOutlet UITextField *eMailText;
    IBOutlet UITextField *netIDText;
    IBOutlet UIButton *submitButton;
    IBOutlet UIButton *resetButton;
    
    NSMutableDictionary *images;
    NSMutableSet *buttonSet; // holds buttons we've seen.
    
    UIActivityIndicatorView *indicator;
    
    int32_t pendingrequests;
}

-(IBAction)TakePhoto:(id)sender;
-(IBAction)ChooseExisting;
- (IBAction)dismissView:(id)sender;
- (IBAction)clearAllButton:(id)sender;
- (IBAction)submitButton:(id)sender;
- (BOOL) isEmailAddressValid: (NSString *) candidate;
- (void) viewDidAppear:(BOOL)animated;
- (void)controlTextDidChange:(NSNotification *)notification;

@end
