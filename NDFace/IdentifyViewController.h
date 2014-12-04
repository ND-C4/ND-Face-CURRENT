//
//  IdentifyViewController.h
//  NDFace
//
//  Created by Patrick J. Flynn on 12/3/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IdentifyViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UITextFieldDelegate,UIGestureRecognizerDelegate> {
    UIImagePickerController *picker;
    UIImage *image;
}

- (IBAction)startButton:(id)sender;

@end
