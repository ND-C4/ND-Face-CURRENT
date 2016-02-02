//
//  EnrollmentConfirmationViewController.m
//  NDFace
//
//  Created by Matt Willmore on 5/12/15.
//  Copyright (c) 2015 Architecture Information Technology Team. All rights reserved.
//

#import "EnrollmentConfirmationViewController.h"

@interface EnrollmentConfirmationViewController ()

@end

@implementation EnrollmentConfirmationViewController



- (void) viewDidLoad
	{
		[super viewDidLoad];

		NSLog (@" ");														// Debug Assist Code
		NSLog (@"ECVC: viewDidLoad");										// Debug Assist Code
		NSLog (@" ");														// Debug Assist Code
		NSLog (@"messageField is %@",self.enrollmentConfirmationLabel);		// Debug Assist Code

        if ((self.enrollmentConfirmationLabel != nil) && (self.storedMessage != nil))
			{
				[self.enrollmentConfirmationLabel setText: self.storedMessage];
			}

//		[EnrollmentConfirmationLabel setText:@"Something happened."];
		
		// Do any additional setup after loading the view.
		
//		[self setMessageField: @"this is a test"]; // writes to the label
		// [self setMessageField: ]; TODO 7-28-15

	}	// End:  viewDidLoad



- (void) didReceiveMemoryWarning
	{
		[super didReceiveMemoryWarning];
		// Dispose of any resources that can be recreated.

	}	// End:  didReceiveMemoryWarning


#pragma mark - Navigation

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	{
		NSLog (@" ");															// Debug Assist Code
		NSLog (@"entering prepareForSegue in ECVC");							// Debug Assist Code
		NSLog (@" ");															// Debug Assist Code
        NSLog (@"messageField is %@", self.enrollmentConfirmationLabel);		// Debug Assist Code

		// Get the new view controller using [segue destinationViewController].
		// Pass the selected object to the new view controller.

	}	// End:  prepareForSegue



- (void) setMessageField: (NSString *) theMessage
	// Send message to the Display Field
	{
		NSString			*aMessageStr;						// The message string


		// How this method works:
		//
		// This method will return the enrollment result message received from the server,
		// abbreviate it, add anything extra and display it to the user.
		//
		// The message returned from the server is scanned for a particular
		// set of words in order to provide a short but accurate response to the user.
		//
		// This is an example of an error message from the server.  It is all one line
		// of text but is broken up here in order to show it.
		//
		// Example of an error message:
		//
		//		Face image not enrolled: Error Domain=NSURLErrorDomain Code=-1004 "Could not connect to the server."
		//		UserInfo={NSUnderlyingError=0x7faf6b474b20 {Error Domain=kCFErrorDomainCFNetwork Code=-1004 "Could not connect to the server."
		//		UserInfo={NSErrorFailingURLStringKey=http://flynnuc.cse.nd.edu:8776/enroll/c@nd.edu/nohfplmvsfdjtink,
		//		NSErrorFailingURLKey=http://flynnuc.cse.nd.edu:8776/enroll/c@nd.edu/nohfplmvsfdjtink, _kCFStreamErrorCodeKey=61,
		//		_kCFStreamErrorDomainKey=1, NSLocalizedDescription=Could not connect to the server.}},
		//		NSErrorFailingURLStringKey=http://flynnuc.cse.nd.edu:8776/enroll/c@nd.edu/nohfplmvsfdjtink,
		//		NSErrorFailingURLKey=http://flynnuc.cse.nd.edu:8776/enroll/c@nd.edu/nohfplmvsfdjtink, _kCFStreamErrorDomainKey=1,
		//		_kCFStreamErrorCodeKey=61, NSLocalizedDescription=Could not connect to the server.}

		NSLog (@" ");																	// Debug Assist Code
		NSLog (@"*** setMessageField Called *** with text of:  >%@<", theMessage);		// Debug Assist Code
		NSLog (@" ");																	// Debug Assist Code
        NSLog (@"messageField is %@",self.enrollmentConfirmationLabel);					// Debug Assist Code

		// Search for a known string and generate a message to display to the user
		if ([self string_DoesThisString_ContainThisSubString: theMessage selSubStr: @"Could not connect to the server"])
			{
				aMessageStr = @"Face Image NOT Enrolled.  \n(Could not connect to the server.)";
			}
		else
			{
				// Pass the message through because we don't know how to handle it
				aMessageStr = [theMessage copy];
			}

		// Lead the message to return
		if (self.enrollmentConfirmationLabel != nil)
			{
				NSLog (@"------> Storing the message (Confirmation).");					// Debug Assist Code
				// The text view exists to display the message
				[self.enrollmentConfirmationLabel setText: aMessageStr];
			}
        else
			{
				NSLog (@"------> Storing the message (Stored).");						// Debug Assist Code
				// The text view does not exist yet to display the message
				self.storedMessage = [aMessageStr copy];
			}

	}	// End:  prepareForSegue



- (BOOL) string_DoesThisString_ContainThisSubString: (NSString *) theStringToSearchStr selSubStr: (NSString *) theSubStr
	// Determine if a string contains a specified subString
	{
		NSRange				aSearchRange;						// The source string range to search
		NSRange				aRangeResult;						// The range of the SubString within the search string if it is found
		BOOL				aFlag_SubStringFoundStatus;			// Flag that the sub-string was found within the string


		// How this method works:
		//
 		// This will perform a character-by-character search to find the SubString contained within the string to search.
		// The string search is case-sensitive.
		// If the string is found, it will return a boolean YES.
		// If the string is not found, it will return a boolean NO.
		// The SubString can be a single character or a string of characters.
		//
		// Examples:
		//
		//		Given the string "DBRT133_35 Macintosh-Windows - Lab Student Station" to search with the SubString of "35" will return YES.
		//		Given the string "DBRT133_35 Macintosh-Windows - Lab Student Station" to search with the SubString of "33" will return NO.
		//		Given the string "DBRT133_35 Macintosh-Windows - Lab Student Station" to search with the SubString of " - " will return YES.
		//		Given the string "DBRT133_35 Macintosh-Windows - Lab Student Station" to search with the SubString of "Lab" will return YES.
		//		Given the string "DBRT133_35 Macintosh-Windows - Lab Student Station" to search with the SubString of "Labs" will return NO.
		//		Given the string "DBRT133_35 Macintosh-Windows - Lab Student Station" to search with the SubString of "DBRT" will return YES.
		//		Given the string "DBRT133_35 Macintosh-Windows - Lab Student Station" to search with the SubString of "dbrt" will return NO.

		aSearchRange = NSMakeRange (0U, [theStringToSearchStr length]);		// Start at position zero and stop at the last character position of the source string for the range to search

		aRangeResult = [theStringToSearchStr								// The string to search within
							   rangeOfString: theSubStr						// The substring to search for
									 options: NSLiteralSearch				// Exact character-by-character equivalence (case sensitive)
									   range: aSearchRange];				// The source string range to search

		if (aRangeResult.location == NSNotFound) 
			{
				// The SubString was not found
				aFlag_SubStringFoundStatus = NO;							// The SubString was not found
			} 
		else 
			{
				// The SubString was found
				aFlag_SubStringFoundStatus = YES;							// The SubString was found
			}

		return aFlag_SubStringFoundStatus;									// Return the result

	}	// End:  string_DoesThisString_ContainThisSubString

@end
