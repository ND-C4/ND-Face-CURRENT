//
//  EnrollmentConfirmationViewController.h
//  NDFace
//
//  Created by Matt Willmore on 5/12/15.
//  Copyright (c) 2015 C[4]. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnrollViewController.h"

@interface EnrollmentConfirmationViewController : UIViewController
{
}

@property (atomic, strong) IBOutlet UILabel *enrollmentConfirmationLabel;
@property (atomic, strong) NSString *storedMessage;

- (void) setMessageField: (NSString *) theMessage;
	// Send message to the Display Field

- (BOOL) string_DoesThisString_ContainThisSubString: (NSString *) theStringToSearchStr selSubStr: (NSString *) theSubStr;
	// Determine if a string contains a specified subString

@end