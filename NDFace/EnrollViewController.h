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

//  BOOL                            didSetImage;                // flag to determine if picture has been chosen

    // User Entry Fields
    
    IBOutlet UITextField            *firstNameText;
    IBOutlet UITextField            *lastNameText;
    IBOutlet UITextField            *eMailText;
    IBOutlet UITextField            *netIDText;
    IBOutlet UIButton               *button_Enroll;             // The Enroll button
    IBOutlet UIButton               *button_Reset;              // The Reset button
    
    NSMutableDictionary             *images;
    NSMutableSet                    *buttonSet;                  // Holds buttons we've seen.
    
    UIActivityIndicatorView         *indicator;
    
    int32_t                         pendingrequests;

    // Constants
    enum
        {
            kPhotos_MinimumAmountNeeded = (4 - 1)						// The minimum number of Photos needed (Currently 4), index starts at 0 so we subtract 1
        };

}

@property (atomic, strong)      NSString	*fSystem_WorkStr;               // System:  System work string
@property (atomic)              BOOL		fFlag_FirstNameExists;          // Flag to indicate the valid existance of First Name text in the TextView
@property (atomic)              BOOL		fFlag_LastNameExists;           // Flag to indicate the valid existance of Last Name text in the TextView
@property (atomic)              BOOL		fFlag_eMailNameExists;          // Flag to indicate the valid existance of E-Mail text in the TextView
@property (atomic)              BOOL		fFlag_NetIDNameExists;          // Flag to indicate the valid existance of NetID text in the TextView
@property (atomic)              BOOL		fFlag_RequiredPhotosExists;     // Flag to indicate the valid existance of the number of required Photos


- (IBAction) ChooseExisting;
- (IBAction) dismissView:(id) sender;
- (BOOL) isEmailAddressValid: (NSString *) candidate;

- (IBAction) button_TakePhoto: (id) sender;
    // Take a Photograph

- (IBAction) button_Reset:(id) sender;
    // Reset and Clear all of the User input fields and Photographs

- (IBAction) button_Enroll:(id) sender;
    // Enroll Button (Button on Second View)

- (void) check_EnableDisable_EnrollButton;
	// Enable or Disable the Enroll button

- (BOOL) string_IsTheStringEmpty: (NSString *) theStr;
	// Check for an empty string

@end
