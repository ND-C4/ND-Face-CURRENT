//
//  EnrollViewController.m
//  NDFace
//
//  Created by Abe on 3/10/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import "EnrollViewController.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking.h>

@interface EnrollViewController ()

@end

@implementation EnrollViewController

- (void)sendPic:(UIImage *)facePicture //added 3-25-14 to test getting response from web service
{
    NSData *facePictureData = UIImagePNGRepresentation(facePicture);
    
    NSString *url = @"http://cheepnis.cse.nd.edu:5000/enroll/666/1";
    // Argument 2 ("666" for testing) is user ID
    // Argument 3 ("1" for testing) is picture's ID for that user ID
    
    //NSDictionary *parameters = @{@"image": facePictureData};
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [requestManager POST:url
              parameters:@{@"firstName":firstNameText.text,@"lastName":lastNameText.text,@"emailAddress":eMailText.text,@"NetID":netIDText.text} // added parameters to send metadata; need to confim with Pat that this is received properly
constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:facePictureData name:@"image" fileName:@"test.png" mimeType:@"application/octet-stream"];
}
                 success: ^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"success! %@",responseObject );
                 }
                 failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"fail! %@", error);
                 }
     
     ];
    
    
 }

-(IBAction)TakePhoto
{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;

    [self presentViewController:picker animated:YES completion:Nil];

}

-(IBAction)ChooseExisting
{
    picker2 = [[UIImagePickerController alloc] init];
    picker2.delegate = self;
    [picker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker2 animated:YES completion:Nil];
    
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)clearAllButton:(id)sender {
    
    firstNameText.text = @"";
    lastNameText.text = @"";
    eMailText.text = @"";
    netIDText.text = @"";
    imageView.image =[UIImage imageNamed:@"man-silhouette.png"];
    didSetImage = NO;   // reset flag that indicates image has been selected
    
}

- (BOOL) isEmailAddressValid: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (IBAction)submitButton:(id)sender {
    
    if (!didSetImage) // did user submit an image?
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Image"
                                                            message:@"Please supply your picture before continuing."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
      
        } else {
            

    // ensure all requisite fields have been completed
    if ([firstNameText.text isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing First Name"
                                                            message:@"Please supply your first (given) name before continuing."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        } else {
            
            if ([lastNameText.text isEqualToString:@""])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Last Name"
                                                                message:@"Please supply your last (family) name before continuing."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                return;

                
            } else {
                
                if ([eMailText.text isEqualToString:@""] || ![self isEmailAddressValid:eMailText.text])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing or Invalid Email Address"
                                                                    message:@"Please supply a valid email address before continuing."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    return;

                } else {
        
                        // we are good, go ahead and run everything
                        UIImage* imageToSave = [imageView image];
         //             UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
         //             [self markFaces:imageView];
                        [self sendPic:imageToSave];

            }
        }

    }

}
    }

-(void)imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"iPC:dFPMWI: info %@",info);
    NSLog(@"iPC:dFPMWI: image size %@",NSStringFromCGSize(image.size));
    image = [self markFaces:image];
    [imageView setImage: image] ;
    [self dismissViewControllerAnimated:YES completion:Nil];
    
    
}

-(void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}

- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(UIImage *)markFaces:(UIImage *)facePicture
{
    NSLog(@"markFaces: facePicture = %@",facePicture);
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    CIImage* ciimage = [[CIImage alloc] initWithCGImage:facePicture.CGImage];
    
    // create an array containing all the detected faces from the detector
    //    NSLog(@"facePicture.CIImage = %@", ciimage);
    //    NSLog(@"facePicture.CIImage extent: %@",NSStringFromCGRect(ciimage.extent));
    
    NSArray* features = [detector featuresInImage:ciimage];
    //NSLog(@"feature detector found %d features",features.count);
    
    if (features.count != 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Face detection failed"
                                                        message:[NSString stringWithFormat:@"One face was expected, %d were detected.",features.count]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
    CIFaceFeature *faceFeature = [features objectAtIndex:0];
    NSLog(@"markFaces: faceFeature bounds %@",NSStringFromCGRect(faceFeature.bounds));

    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[CIImage imageWithCGImage:facePicture.CGImage] fromRect:faceFeature.bounds];
    NSLog(@"cgImage is %@",cgImage);
    
    UIImage *theImage = [UIImage imageWithCGImage:cgImage];
    NSLog(@"markFaces: theImage = %@ size %@",theImage,NSStringFromCGSize(theImage.size));

//        CGRect newBounds = CGRectMake(faceFeature.bounds.origin.x, ciimage.extent.size.height - faceFeature.bounds.origin.y, faceFeature.bounds.size.width, faceFeature.bounds.size.height);
//        theImage = [self imageByCropping:facePicture toRect:newBounds];
        UIImageWriteToSavedPhotosAlbum(theImage, nil, nil, nil);
    //    [self sendPic:[self imageByCropping:facePicture toRect:newBounds]];
    NSLog(@"out of for loop");


    return theImage;
}



@end
