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
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:image];
    NSLog(@"After Array is createe");
    
    for(CIFaceFeature* faceFeature in features)
    {
        CGRect newBounds = CGRectMake(faceFeature.bounds.origin.x, facePicture.image.size.height - faceFeature.bounds.origin.y, faceFeature.bounds.size.width, -faceFeature.bounds.size.height);
        UIImageWriteToSavedPhotosAlbum([self imageByCropping:facePicture.image toRect:newBounds],nil, nil, nil);
        
    }
    NSLog(@"out of for loop");
}



@end
