//
//  EnrollViewController.h
//  NDFace
//
//  Created by Abe on 3/10/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnrollViewController : UIViewController <UIImagePickerControllerDelegate,
                                                     UINavigationControllerDelegate,
                                                                UITextFieldDelegate,
                                                        UIGestureRecognizerDelegate>
{
    UIImagePickerController         *picker;
    //UIImagePickerController       *picker2;
    UIImage                         *image;
    //IBOutlet UIImageView          *imageView;

    UIButton                        *theButton;                 // Which image button was pressed to take an image?

    BOOL                            didSetImage;                // flag to determine if picture has been chosen
    BOOL                            aFlag_CanContinue;          // Flag to determine if we can continue through the process

    // User Entry Fields
    
    IBOutlet UITextField            *firstNameText;
    IBOutlet UITextField            *lastNameText;
    IBOutlet UITextField            *eMailText;
    IBOutlet UITextField            *netIDText;
    IBOutlet UIButton               *submitButton;
    IBOutlet UIButton               *resetButton;
    
    NSMutableDictionary             *images;
    NSMutableSet                    *buttonSet;                  // Holds buttons we've seen.
    
    UIActivityIndicatorView         *indicator;
    
    int32_t                         pendingrequests;
}

@property (atomic, strong)      NSString	*fSystem_WorkStr;           // System:  System work string
@property (atomic)              BOOL		fFlag_FirstNameExists;      // Flag to indicate the valid existance of First Name text in the TextView
@property (atomic)              BOOL		fFlag_LastNameExists;       // Flag to indicate the valid existance of Last Name text in the TextView
@property (atomic)              BOOL		fFlag_eMailNameExists;      // Flag to indicate the valid existance of E-Mail text in the TextView
@property (atomic)              BOOL		fFlag_NetIDNameExists;      // Flag to indicate the valid existance of NetID text in the TextView
@property (atomic)              BOOL		fFlag_EnableEnrollButton;   // Flag to indicate the Enroll Button can be enabled


- (IBAction) TakePhoto:(id) sender;
- (IBAction) ChooseExisting;
- (IBAction) dismissView:(id) sender;
- (IBAction) clearAllButton:(id) sender;
- (IBAction) submitButton:(id) sender;
- (BOOL) isEmailAddressValid: (NSString *) candidate;
- (void) viewDidAppear: (BOOL) animated;
- (void) controlTextDidChange: (NSNotification *) notification;

- (BOOL) string_IsTheStringEmpty: (NSString *) theStr;
	// Check for an empty string

@end
