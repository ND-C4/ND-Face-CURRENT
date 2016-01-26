//
//  EnrollViewController.m
//  NDFace
//
//  Created by Abe on 3/10/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import "AppDelegate.h"
#import "EnrollViewController.h"
#import "EnrollmentConfirmationViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking.h>
#import <iToast.h>
#import "math.h"
#import <libkern/OSAtomic.h>   // Ride 'em, cowboy!

@interface EnrollViewController ()
@property (strong,atomic) EnrollmentConfirmationViewController *ecvc;

@end

@implementation EnrollViewController

- (void) viewDidAppear: (BOOL) animated		// Override
{
    if (DEBUG) NSLog (@"ViewDidAppear");

    [super viewDidAppear: animated];

    if (images == nil)
		{
			images = [[NSMutableDictionary alloc] init];
		}
    if (buttonSet == nil)
		{
			buttonSet = [[NSMutableSet alloc] init];
		}

	// In order to enable the Enroll button, the required text and pictures must exist
	// Here, we check as pictures are being entered

	[self check_EnableDisable_EnrollButton];			// Enable or Disable the Enroll Button

}	// End: viewDidAppear



- (void) viewDidLoad		// Override
	{
		if (DEBUG) NSLog (@"viewDidLoad");
		[super viewDidLoad];
        self.ecvc=nil;

		if (indicator == nil)
			{
				indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
				if (DEBUG) NSLog (@"allocated indicator");
			}

		// Setting delegates to determine if fields are populated
		[firstNameText setDelegate: self];
		[lastNameText setDelegate: self];
		[eMailText setDelegate: self];
		[netIDText setDelegate: self];

		// Set Control States
		[button_Reset setEnabled: YES];			// Disable the Reset button
		[button_Enroll setEnabled: NO];			// Disable the Enroll button

		// Clear text entry flags
		self.fFlag_FirstNameExists = NO;		// Clear the flag
		self.fFlag_LastNameExists = NO;			// Clear the flag
		self.fFlag_eMailNameExists = NO;		// Clear the flag
		self.fFlag_NetIDNameExists = NO;		// Clear the flag
		self.fFlag_RequiredPhotosExists = NO;	// Clear the flag
        
        self.serverMessageReplyStr = nil;

		// Add notifications when text changes in a particular UITextField
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (textDidChange:) name: UITextFieldTextDidChangeNotification object: firstNameText];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (textDidChange:) name: UITextFieldTextDidChangeNotification object: lastNameText];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (textDidChange:) name: UITextFieldTextDidChangeNotification object: eMailText];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (textDidChange:) name: UITextFieldTextDidChangeNotification object: netIDText];

		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (notification_ShowMessage:) name: @"notificationMessage_ShowServerReplyMessage" object: nil];

	}	// End: viewDidLoad

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
	{
		NSLog (@" ");
		NSLog (@"****** prepareForSegue was called ******");

		EnrollmentConfirmationViewController *destination = [segue destinationViewController];
        self.ecvc = destination; // save for use inside enrollment completion blocks

		BOOL test = [destination isKindOfClass:[EnrollmentConfirmationViewController class]];
        if (test == NO) {
            return;
        }
        
        NSLog (@"Entering prepareForSegue in EnrollViewController...");

		if ([self.serverMessageReplyStr isEqualToString: @""] || self.serverMessageReplyStr == nil)
			{
				// There were no errors
				NSLog (@"serverMessageReplyStr is empty (or no errors)");
				self.serverMessageReplyStr = @"Data Transferred to server.";

			}
		else
			{
				// There was an error, show it to the user
				self.serverMessageReplyStr = @"Hello???";

				NSLog (@"serverMessageReplyStr is %@", self.serverMessageReplyStr);
			}

		// Pass message to setMessageField in destination view controller
		[destination setMessageField: self.serverMessageReplyStr];

		// Get the new view controller using [segue destinationViewController].
		// Pass the selected object to the new view controller.
}



#pragma mark - Buttons

- (IBAction) button_TakePhoto: (id) sender
    // Take a Photograph
	{
		if (DEBUG) NSLog (@"button_TakePhoto: sender %@", sender);

		picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		theButton = sender;
		[buttonSet addObject: sender];

		// Guard logic; should help this guy run correctly on the simulator
		if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
			{
				[self chooseCamera: sender];
			}
		else
			{
				[self chooseLibrary: sender];
			}

		[self presentViewController: picker animated: YES completion: Nil];

	}	// End:  button_TakePhoto



- (IBAction) button_Reset: (id) sender;
    // Reset and Clear all of the User input fields and Photographs
	{
    //    NSLog(@"button_Reset has been called");
		firstNameText.text = @"";
		lastNameText.text = @"";
		eMailText.text = @"";
		netIDText.text = @"";
		[images removeAllObjects];

		// Place a silouette image in all of the Picture Buttons
		for (UIButton *b in [buttonSet allObjects])
			{
				[b setImage: [UIImage imageNamed: @"man-silhouette.png"] forState: UIControlStateNormal];
			}

		[buttonSet removeAllObjects];

		[button_Enroll setEnabled: NO];									// Disable the Enroll button

		//imageView.image =[UIImage imageNamed: @"man-silhouette.png"];
		//didSetImage = NO;   // reset flag that indicates image has been selected

	}	// End:  button_Reset



- (IBAction) button_Enroll: (id) sender;
// Enroll Button (Button on Second View)
{
    
    if (DEBUG) NSLog(@"button_Enroll.");
    if (DEBUG) NSLog (@"good! %ld images to send",(unsigned long)[images count]);
				// We are good, go ahead and run everything
				pendingrequests = 0;
				indicator.center = [self view].center;
				[[self view] addSubview: indicator];
				for (NSString *key in [images allKeys])
                {
                    UIImage* imageToEnroll = [images objectForKey: key];
                    NSLog (@"iterating: key %@",key);
                    [self sendPic: imageToEnroll];
                }
        
} // End:  button_Enroll

#pragma mark - orientation configuration

- (BOOL) shouldAutorotate		// Override
	{
		return NO;

	}	// End:  shouldAutorotate



- (UIInterfaceOrientationMask) supportedInterfaceOrientations		// Override
	{
		return UIInterfaceOrientationMaskPortrait;

	}	// End:  supportedInterfaceOrientations

#pragma mark - camera/album switching, front/back camera switching

// these four methods handle flipping the UIImagePickerController from
// photo album mode to live camera mode, and choosing the front or back camera

- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated		// Override
	{
		// If the camera is available, show the button to activate it.
		if ((picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) || (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
			{
				if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
					{
						UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCamera target: self action: @selector (chooseCamera:)];
						viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject: button];
						viewController.navigationItem.title = @"Choose Photo";
						viewController.navigationController.navigationBarHidden = NO; // important
					}
			}
		else
			{
				// camera is active; show album button and, if available, front/rear camera button
				UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target: self action: @selector (chooseLibrary:)];
				if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] &&
					[UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
					{
						UIImage *cameraToggle = [UIImage imageNamed: @"CameraToggle"];
						UIBarButtonItem *flipCamButton = [[UIBarButtonItem alloc]
														  initWithImage: cameraToggle style: UIBarButtonItemStyleBordered target: self action: @selector (flipCamera:)];
						viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: button, flipCamButton, nil];
					}
				else
					{
						viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: button, nil];
					}

				viewController.navigationItem.title = @"Take Photo";
				viewController.navigationController.navigationBarHidden = NO; // Important
			}

	}	// End:  navigationController



- (void) chooseCamera: (id) sender {
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice=UIImagePickerControllerCameraDeviceFront;
    picker.showsCameraControls = YES;
    
}

- (void) chooseLibrary: (id) sender {
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void) flipCamera: (id) sender {
    if (DEBUG) NSLog(@"flipCamera");
    if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

- (NSString*)generateRandomString:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}




- (void) sendPic: (UIImage *) facePicture
	{
		NSLog (@" ");
		NSLog (@"****** sendPic was called ******");

		NSData *facePictureData = UIImagePNGRepresentation(facePicture);
		// very verbose.
		//if (DEBUG) NSLog(@"facePictureData %@",facePictureData);
		NSString *netid = [eMailText text];
		if ([netid length] == 0)
			netid = [self generateRandomString:10];

/*		NSString *url = [NSString stringWithFormat:@"http://10.10.138.48:5000/enroll/%@/%@",netid,[self generateRandomString:16]]; */
		NSString *url = [NSString stringWithFormat:@"http://flynnuc.cse.nd.edu:8776/enroll/%@/%@",netid,[self generateRandomString:16]];
		if (DEBUG) NSLog(@"url: %@",url);
		
		//NSString *url = @"http://flynnuc.cse.nd.edu:5000/enroll/666/1";
		// Argument 2 ("666" for testing) is user ID
		// Argument 3 ("1" for testing) is picture's ID for that user ID
		
		//NSDictionary *parameters = @{@"image": facePictureData};
		
		AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
		requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
		if (DEBUG) NSLog(@"requestManager: %@",requestManager);

		[indicator startAnimating];
		OSAtomicIncrement32 (&pendingrequests);
		[requestManager POST:url
				  parameters:@{@"firstName":firstNameText.text,
							   @"lastName":lastNameText.text,
							   @"emailAddress":eMailText.text,
							   @"NetID":netIDText.text}
	constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
	{
		[formData appendPartWithFileData:facePictureData name:@"image" fileName:@"test.png" mimeType:@"application/octet-stream"];
	}

					 success: ^(AFHTTPRequestOperation *operation, id responseObject)
						 {
							 [[iToast makeText: @"Face image enrolled."] show];
							 if (DEBUG) NSLog (@"success! %@",responseObject );
							 OSAtomicDecrement32 (&pendingrequests);
							 if (pendingrequests == 0)
								 {
									 [indicator stopAnimating];
									 [indicator removeFromSuperview];
								 }

                             if (self.ecvc != nil)
                             {
                                 [self.ecvc setMessageField:@"Successful enrollment."];
                             }
//                             AppDelegate *ad = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//                             if (ad.ecvc != nil)
//                             {
//                                 [ad.ecvc setMessageField:@"Successful enrollment."];
//                             }
						 }

					 failure: ^(AFHTTPRequestOperation *operation, NSError *error)
						 {
							 NSString    *aLocalStr;


							 aLocalStr = [NSString stringWithFormat:@"Face image not enrolled: %@",error];

                             // parse error code into useful info here.
							 NSLog (@" ");
							 NSLog (@"aLocalStr contains: %@", aLocalStr);
							 NSLog (@" ");

							 self.serverMessageReplyStr = [NSString stringWithString:aLocalStr];

							 NSLog (@" ");
							 NSLog (@"serverMessageReplyStr contains: %@", self.serverMessageReplyStr);
							 NSLog (@" ");

                             // this may no longer be needed. Jeff
							[[NSNotificationCenter defaultCenter] postNotificationName: @"notificationMessage_ShowServerReplyMessage" object: self];		// Send the notification



//							[[iToast makeText: serverMessageReplyStr] show];

							 if (DEBUG) NSLog (@"sendPic fail! %@", error);

//							 AppDelegate *ad = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                             if (self.ecvc != nil)
                             {
                                 [self.ecvc setMessageField: self.serverMessageReplyStr];
                             }

//							 AppDelegate *ad = (AppDelegate *) [[UIApplication sharedApplication] delegate]
//                             if (ad.ecvc != nil)
//                             {
//                                 EnrollmentConfirmationViewController *ecvc = ad.ecvc;
//                                 [ecvc setMessageField: self.serverMessageReplyStr];
//                             }

//							OSAtomicDecrement32(&pendingrequests);
//							if (pendingrequests == 0)
//								{
//									[indicator stopAnimating];
//									[indicator removeFromSuperview];
//								}
				
							 
							// Look within the error message to determine the error and send a sanitized version to EnrollConfirmationLabel

/*
							EnrollmentConfirmationViewController *aViewController;
							aViewController = [[EnrollmentConfirmationViewController alloc] init];
							NSLog(@"setMessageField test");
							[aViewController setMessageField: @"test 2"];
*/
						 }

		 ];
		
		
	}

- (void) notification_ShowMessage: (NSNotification *) theNotification
	// Notification:  Show Message to the User
	{
		NSLog (@" ");
		NSLog (@"*** notification_ShowMessage has been sent *** with message:  >%@<", self.serverMessageReplyStr);
		NSLog (@" ");

		EnrollmentConfirmationViewController	*anEnrollmentConfirmationViewController;
		[anEnrollmentConfirmationViewController setMessageField: self.serverMessageReplyStr];	// Send the message to the text field
	}


- (IBAction) dismissView: (id) sender
	{
		[self dismissViewControllerAnimated: YES completion: Nil];
	}



- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
	{
		image = [info objectForKey: UIImagePickerControllerOriginalImage];
		if (DEBUG) NSLog (@"iPC:dFPMWI: info %@", [info description]);
		if (DEBUG) NSLog (@"iPC:dFPMWI: image %@", image);
		if (DEBUG) NSLog (@"iPC:dFPMWI: image size %@", NSStringFromCGSize (image.size));

		image = [self markFaces: image];
		if (image == nil)
			{
				NSLog (@"Error: failed to get face in image.");
			}
		else
			{
				[theButton setImage: image forState: UIControlStateNormal];
				[images setValue: image forKey: [theButton description]];
                NSLog (@"images is %@", images);
			}

		[self dismissViewControllerAnimated: YES completion: Nil];

	}	// End: imagePickerController



-(void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
	{
		[self dismissViewControllerAnimated: YES completion: Nil];
		
	}



- (BOOL) isEmailAddressValid: (NSString *) candidate
	{
		NSString *emailRegex =
		@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
		@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
		@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
		@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
		@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
		@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
		@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
		NSPredicate *emailTest = [NSPredicate predicateWithFormat: @"SELF MATCHES[c] %@", emailRegex];
		
		return [emailTest evaluateWithObject: candidate];
	}



// TODO:  What uses this?  Is it needed? --- JJH
//NSString *stringWithUIImageOrientation (UIImageOrientation input)
//	{
//		NSArray *arr = @[
//						 @"UIImageOrientationUp",            // default orientation
//						 @"UIImageOrientationDown",          // 180 deg rotation
//						 @"UIImageOrientationLeft",          // 90 deg CCW
//						 @"UIImageOrientationRight",         // 90 deg CW
//						 @"UIImageOrientationUpMirrored",    // as above but image mirrored along other axis. horizontal flip
//						 @"UIImageOrientationDownMirrored",  // horizontal flip
//						 @"UIImageOrientationLeftMirrored",  // vertical flip
//						 @"UIImageOrientationRightMirrored", // vertical flip
//						 ];
//		return (NSString *) [arr objectAtIndex: input];
//	}



-(UIImage *)markFaces:(UIImage *)facePicture
{
    if (DEBUG) NSLog(@"markFaces: facePicture = %@",facePicture);
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIImage* ciimage = [[CIImage alloc] initWithImage:facePicture];
    int exifOrientation = 0;
    switch ([facePicture imageOrientation]) {
        case UIImageOrientationUp: exifOrientation = 1; break;
        case UIImageOrientationDown:exifOrientation = 3; break;
        case UIImageOrientationLeft: exifOrientation = 8; break;
        case UIImageOrientationRight: exifOrientation = 6; break;
        case UIImageOrientationUpMirrored: exifOrientation = 2; break;
        case UIImageOrientationDownMirrored: exifOrientation = 4; break;
        case UIImageOrientationLeftMirrored: exifOrientation = 5; break;
        case UIImageOrientationRightMirrored: exifOrientation = 7; break;
        default: break;
    }
    
    NSDictionary *fOptions = @{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]};
    if (DEBUG) NSLog(@"fOptions %@",fOptions);
    
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    
    // create an array containing all the detected faces from the detector
    if (DEBUG) NSLog(@"facePicture.CIImage = %@", ciimage);
    if (DEBUG) NSLog(@"facePicture.CIImage extent: %@",NSStringFromCGRect(ciimage.extent));
    
    NSArray* features = [detector featuresInImage:ciimage options:fOptions];
    
    if (DEBUG) NSLog(@"feature detector found %ld features",(unsigned long)features.count);
    
    if (features.count != 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Face detection failed"
                                                        message:[NSString stringWithFormat:@"One face was expected, %ld were detected.",(unsigned long)features.count]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
    // we got a single face. Assume it is the right face, and transmit it to the
    // server.
    CIFaceFeature *faceFeature = [features objectAtIndex:0];
    if (DEBUG) NSLog(@"markFaces: faceFeature bounds %@",NSStringFromCGRect(faceFeature.bounds));
    
    CGPoint pLeft = faceFeature.leftEyePosition;
    CGPoint pRight = faceFeature.rightEyePosition;
    
    if (faceFeature.hasLeftEyePosition) {
        if (DEBUG) { NSLog(@"left eye position: %@",NSStringFromCGPoint(pLeft)); }
    } else {
        if (DEBUG) { NSLog(@"no left eye detected."); }
    }
    if (faceFeature.hasRightEyePosition) {
        if (DEBUG) { NSLog(@"right eye position: %@",NSStringFromCGPoint(pRight)); }
    } else {
        if (DEBUG) {NSLog(@"no right eye detected.");}
    }
    if (faceFeature.hasFaceAngle) {
        if (DEBUG) { NSLog(@"faceAngle: %f",faceFeature.faceAngle); }
    } else {
        if (DEBUG) { NSLog(@"no face angle.");}
    }
    
    
    CGPoint pMouth ;
    if (faceFeature.hasMouthPosition) {
        if (DEBUG) NSLog(@"mouth position: %@",NSStringFromCGPoint(faceFeature.mouthPosition));
        pMouth = faceFeature.mouthPosition;
    }
    else
        if (DEBUG) NSLog(@"no mouth detected.");
    
    // draw nice dots where the features are detected.
    
    
    if (DEBUG) NSLog(@"Smile: %@",faceFeature.hasSmile ? @"yes" : @"no");

    // In this version, we send a cropped face, expanded 25% on each side from the face detector used
    // in this method, to give OpenBR some room for its own detector. We also conditionally rescale the image so that
    // the largest side length of the 25%-expanded rectangle is no more than 512 pixels. We do not need to
    // scale the faces to all be the same size or anything like that.
    
    CGRect b = faceFeature.bounds;
    CGFloat sx = b.size.width, sy = b.size.height;
    CGRect newb = CGRectInset(b, -0.25*sx, -0.25*sy);
    NSLog(@"UIImage extent %@, ciimage extent %@", NSStringFromCGSize(facePicture.size), NSStringFromCGRect(ciimage.extent));
    CGRect clipnewb = CGRectIntersection(newb,ciimage.extent);
    NSLog(@"old Rect %@, new rect %@, new cropped rect %@",NSStringFromCGRect(b), NSStringFromCGRect(newb), NSStringFromCGRect(clipnewb));
    
    CGImageRef imref = CGImageCreateWithImageInRect([facePicture   CGImage], clipnewb);
    UIImage *croppedFace = [UIImage imageWithCGImage:imref];
    UIImage *resizedCroppedFace;
    CGSize s;
    if (clipnewb.size.width > clipnewb.size.height) { // scale along x
        s = CGSizeMake(512, 512*clipnewb.size.height/clipnewb.size.width);
    } else { //scale along y
        s = CGSizeMake(512*clipnewb.size.width/clipnewb.size.height, 512);
    }
    UIGraphicsBeginImageContext(s);
    [croppedFace drawInRect:CGRectMake(0,0,s.width,s.height)];
    resizedCroppedFace = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return facePicture;
    return resizedCroppedFace;
}



// Dismiss the keyboard when we click "Done"
- (BOOL) textFieldShouldReturn: (UITextField *) textField
	{
		[textField resignFirstResponder];
		return NO;
	}



- (void) textFieldDidEndEditing: (UITextField *) textField		// Overidden
	// Text Did End Editing
	{
		// We only want to check the E-Mail Address data form
		if (textField == eMailText)
			{
				// The user finished typing in the E-Mail Address so we make sure it is in proper form
				if ( ![self isEmailAddressValid: eMailText.text] )
					{
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Missing or Invalid Email Address"
																		message: @"Please supply a valid email address before continuing."
																	   delegate: nil
															  cancelButtonTitle: @"OK"
															  otherButtonTitles: nil];
						[alert show];
					}
			}

	}	// End:  textFieldDidEndEditing



- (void) textDidChange: (NSNotification *) theNotification		// Overidden
	// Text Did Change
	{
		// How this method works:
		//
		// As text is entered into a UITextField, this method
		// is automatically called.
		//
		// We set a flag associated with the UITextField being entered as well as
		// checking it to make sure there is something there so that we know what
		// text field has data and can issue missing data errors to the user.
		//
		// We check for entered text in this manner because there is no button
		// that gets pressed to perform the checks.  We rely on flags set in
		// real time.
		//
		// Data checks can be made using the individual flags or the result
		// flag that is set.


		// **************************************
		// * Check First Name text				*
		// **************************************

		if ([theNotification object] == firstNameText)
			{
				if ([self string_IsTheStringEmpty: firstNameText.text])		// Check for an empty string
					self.fFlag_FirstNameExists = NO;						// There is no text present
				else
					self.fFlag_FirstNameExists = YES;						// There is text present
			}

		// **************************************
		// * Check Last Name text				*
		// **************************************

		if ([theNotification object] == lastNameText)
			{
				if ([self string_IsTheStringEmpty: lastNameText.text])		// Check for an empty string
					self.fFlag_LastNameExists = NO;							// There is no text present
				else
					self.fFlag_LastNameExists = YES;						// There is text present
			}

		// **************************************
		// * Check E-Mail text					*
		// **************************************

		if ([theNotification object] == eMailText)
			{
				if ([self string_IsTheStringEmpty: eMailText.text])			// Check for an empty string
					self.fFlag_eMailNameExists = NO;						// There is no text present
				else
					self.fFlag_eMailNameExists = YES;						// There is text present
			}

		// **************************************
		// * Check NetID text					*
		// **************************************

		if ([theNotification object] == netIDText)
			{
				if ([self string_IsTheStringEmpty: netIDText.text])			// Check for an empty string
					self.fFlag_NetIDNameExists = NO;						// There is no text present
				else
					self.fFlag_NetIDNameExists = YES;						// There is text present
			}

		// **************************************
		// * Update Controls					*
		// **************************************

		// In order to enable the Enroll button, the required text and pictures must exist
		// Here, we check as text is being entered

		[self check_EnableDisable_EnrollButton];							// Enable or Disable the Enroll Button

	}	// End:  textFieldDidEndEditing

- (void) check_EnableDisable_EnrollButton
	// Enable or Disable the Enroll button
	{
		// How this method works:
		//
		// FLags are set when text is entered into the required fields and
		// when the proper number of photos have been taken.
		//
		// These Flags can be set in any order so this is where the the
		// Flags are processed to determine if the Enroll button is to
		// be Enabled or Disabled.

		// Check if we have the current minimum amount of Photos required
		if ([images count] < (NSUInteger) kPhotos_MinimumAmountNeeded)			// The minimum number of Photos required (images starts counting at 0)
			{
				// The minimum number of Photos is not met
				self.fFlag_RequiredPhotosExists = NO;							// Set flag to condition is not met
			}
		else
			{
				// The minimum number of Photos is met
				self.fFlag_RequiredPhotosExists = YES;                          // Set flag to condition is met
			}

		// Enable or Disable the Enroll button based on all criteria being met
		if (self.fFlag_FirstNameExists &&
			self.fFlag_LastNameExists &&
			self.fFlag_eMailNameExists &&
			self.fFlag_NetIDNameExists &&			// We may want to remove the NetID since it is not required
			self.fFlag_RequiredPhotosExists)
			{
				// All of the User text fields have text
				[button_Enroll setEnabled: YES];								// Enable the Enroll button

				if (DEBUG) NSLog (@"ENABLE Enroll button, All data is available");		// Debug Assist Code
			}
		else
			{
				// Some of the User text fields are missing text
				[button_Enroll setEnabled: NO];									// Disable the Enroll button

//				if (DEBUG) NSLog (@"DISABLE Enroll button, Some data is missing; image count is %d", [images count]);		// Debug Assist Code
//                NSLog(@"first name flag is %d", self.fFlag_FirstNameExists);
//                NSLog(@"last name flag is %d", self.fFlag_LastNameExists);
//                NSLog(@"email flag is %d", self.fFlag_eMailNameExists);
//                NSLog(@"netid flag is %d", self.fFlag_NetIDNameExists);
			}

	}	// End:  check_EnableDisable_EnrollButton



- (BOOL) string_IsTheStringEmpty: (NSString *) theStr
	// Check for an empty string
	{
		NSString			*aWorkStr;							// A work string
		BOOL				aFlag_StringIsEmptyResult;			// String is empty flag


		// How this method works:
		//
		// An empty string can be classified in a number of ways.  This method handles all of them.
		//
		// The checking includes the string being null, nil, empty and only containing whitespace
		// characters (space, tab, newline).  These conditions define an empty string.
		//
		// Given a string, return "YES" if the string is empty or "NO" if it has a value.
		
		aWorkStr = theStr;															// Get a copy of the string
		aFlag_StringIsEmptyResult = NO;												// Clear the empty state flag

		if ( (NSNull *) aWorkStr == [NSNull null] )
			{
				// String is null
				aFlag_StringIsEmptyResult = YES;									// Set the empty state flag
			}

		if (aWorkStr == nil)
			{
				// String is nil
				aFlag_StringIsEmptyResult = YES;									// Set the empty state flag
			} 
		else if ([aWorkStr length] == 0U)
			{
				// String is empty
				aFlag_StringIsEmptyResult = YES;									// Set the empty state flag
			}
		else
			{
				// Check for the whitespace characters; space, tab and the newline character
				aWorkStr = [aWorkStr stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];		// Remove whitespace from around the string
				if ([aWorkStr length] == 0U)
					{
						aFlag_StringIsEmptyResult = YES;							// Set the empty state flag
                        
					}
			}
        
		return aFlag_StringIsEmptyResult;											// Return the string state flag

	}	// End:  string_IsTheStringEmpty
@end
