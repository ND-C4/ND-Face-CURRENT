//
//  EnrollmentConfirmationViewController.h
//  NDFace
//
//  Created by Matt Willmore on 5/12/15.
//  Copyright (c) 2015 C[4]. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnrollmentConfirmationViewController : UIViewController {

IBOutlet UILabel *EnrollmentConfirmationLabel;

}

-(void) setMessageField:(NSString *) theMessage;

@end