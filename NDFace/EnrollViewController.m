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

@interface EnrollViewController ()

@end

@implementation EnrollViewController

- (void)sendPic:(UIImage *)facePicture //added 3-25-14 to test getting response from web service
{
    NSData *facePictureData = UIImagePNGRepresentation(facePicture);
    
    NSString *url = @"http://cheepnis.cse.nd.edu:5000/enroll/666/1";
    // Argument 2 ("666" for testing) is user ID
    // Argument 3 ("1" for testing) is picture's ID for that user ID
    
    NSURL *reqUrl = [[NSURL alloc] initWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:reqUrl];
    NSError *error;
    NSURLResponse *response;
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"foo";
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"Test.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:facePictureData]];
    
    NSLog(@"%@",[body description]);
   
    [request setHTTPBody:body];

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        // Process any errors
        NSString *errorStr = [NSString stringWithString:[error description]];
        NSLog(@"ERROR: Unable to make connection to server; %@", errorStr);
    }
    
    NSStringEncoding responseEncoding = NSUTF8StringEncoding;
    if ([response textEncodingName]) {
        CFStringEncoding cfStringEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]);
        if (cfStringEncoding != kCFStringEncodingInvalidId) {
            responseEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding);
        }
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:responseEncoding];
    
    NSLog(@"return data %@", dataString);
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
    
}

- (IBAction)submitButton:(id)sender {
    UIImage* imageToSave = [imageView image];
    UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
    [self markFaces:imageView];
}

-(void)imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
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

-(void)markFaces:(UIImageView *)facePicture
{
    // draw a CI image with the previously loaded face detection picture
    CIImage* lImage = [CIImage imageWithCGImage:facePicture.image.CGImage];
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:lImage];
    NSLog(@"After Array is created");
    
    for(CIFaceFeature* faceFeature in features)
    {
        CGRect newBounds = CGRectMake(faceFeature.bounds.origin.x, facePicture.image.size.height - faceFeature.bounds.origin.y, faceFeature.bounds.size.width, -faceFeature.bounds.size.height);
        UIImageWriteToSavedPhotosAlbum([self imageByCropping:facePicture.image toRect:newBounds],nil, nil, nil);
        [self sendPic:[self imageByCropping:facePicture.image toRect:newBounds]];
    }
    NSLog(@"out of for loop");
}



@end
