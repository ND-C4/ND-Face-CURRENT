//
//  EnrollViewController.h
//  NDFace
//
//  Created by Abe on 3/10/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnrollViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate>
{
    UIImagePickerController *picker;
    UIImagePickerController *picker2;
    UIImage *image;
    IBOutlet UIImageView *imageView;
    BOOL didSetImage;                   // flag to determine if picture has been chosen 

    
    
    IBOutlet UITextField *firstNameText;
    IBOutlet UITextField *lastNameText;
    IBOutlet UITextField *eMailText;
    IBOutlet UITextField *netIDText;
    
    
}

-(IBAction)TakePhoto;
-(IBAction)ChooseExisting;
- (IBAction)dismissView:(id)sender;
- (IBAction)clearAllButton:(id)sender;
- (IBAction)submitButton:(id)sender;
- (BOOL) isEmailAddressValid: (NSString *) candidate;


@end
