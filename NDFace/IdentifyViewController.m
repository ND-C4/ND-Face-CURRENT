//
//  IdentifyViewController.m
//  NDFace
//
//  Created by Patrick J. Flynn on 12/3/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import "IdentifyViewController.h"
#import <AFNetworking.h>
#import <iToast.h>


@interface IdentifyViewController ()

@end

@implementation IdentifyViewController



- (void)viewDidLoad {
    if (DEBUG) NSLog(@"IVC:vDL");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - actions

- (IBAction)startButton:(id)sender {
    if (DEBUG) NSLog(@"IVC:start");
    if (DEBUG) NSLog(@"TakePhoto: sender %@",sender);
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    // guard logic; should help this guy run correctly on the simulator
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self chooseCamera:sender];
    } else {
        [self chooseLibrary:sender];
    }
    [self presentViewController:picker animated:YES completion:Nil];

}


- (void)sendPic:(UIImage *)facePicture {
    NSData *facePictureData = UIImagePNGRepresentation(facePicture);
    NSString *url = [NSString stringWithFormat:@"http://cheepnis.cse.nd.edu:5000/match"];
    if (DEBUG) NSLog(@"url: %@",url);
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (DEBUG) NSLog(@"requestManager: %@",requestManager);
    
    [requestManager POST:url
              parameters:@{}
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:facePictureData name:@"image" fileName:@"test.png" mimeType:@"application/octet-stream"];
}
                 success: ^(AFHTTPRequestOperation *operation, id responseObject) {
                     [[iToast makeText:
                       [NSString stringWithFormat:@"THe person in this picture is %@",[responseObject objectForKey:@"id"]]] show];
                     if (DEBUG) NSLog(@"success! %@",responseObject );
                 }
                 failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSString *e = [NSString stringWithFormat:@"Face image not transmitted: %@",error];
                     [[iToast makeText:e] show];
                     if (DEBUG) NSLog(@"fail! %@", error);
                 }
     
     ];
    
    
}



#pragma mark - UIImgePickerController custom control handlers

// these four methods handle flipping the UIImagePickerController from
// photo album mode to live camera mode, and choosing the front or back camera

- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated {
    // if camera available, show the button to activate it.
    if ((picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) || (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(chooseCamera:)];
            viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
            viewController.navigationItem.title = @"Choose Photo";
            viewController.navigationController.navigationBarHidden = NO; // important
        }
    } else {
        // camera is active; show album button and, if available, front/rear camera button
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(chooseLibrary:)];
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] &&
            [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            UIImage *cameraToggle = [UIImage imageNamed:@"CameraToggle"];
            UIBarButtonItem *flipCamButton = [[UIBarButtonItem alloc]
                                              initWithImage:cameraToggle style:UIBarButtonItemStyleBordered target:self action:@selector(flipCamera:)];
            viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:button,flipCamButton,nil];
        } else {
            viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:button,nil];
        }
        viewController.navigationItem.title = @"Take Photo";
        viewController.navigationController.navigationBarHidden = NO; // important
    }
}

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

#pragma mark - image capture handler methods

-(void)imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (DEBUG) NSLog(@"iPC:dFPMWI: info %@",info);
    if (DEBUG) NSLog(@"iPC:dFPMWI: image %@",image);
    if (DEBUG) NSLog(@"iPC:dFPMWI: image size %@",NSStringFromCGSize(image.size));
    image = [self markFaces:image];
    [self sendPic:image];
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
    
    if (DEBUG) NSLog(@"feature detector found %ld features",features.count);
    
    if (features.count != 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Face detection failed"
                                                        message:[NSString stringWithFormat:@"One face was expected, %ld were detected.",features.count]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
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
    
    // set up the transform. We are going to map the face to a 150 row x 130 column
    // image, with subject's right eye going to (x=30, y=45) and the subject's left eye
    // going to (x=100,y=45). This is in keeping with the good old csuPreprocessNormalize
    // code from the CSUFaceIdEval package.
    
    // just a side rant. Why the (*#&$ does Apple make you specify transforms
    // the hard way?
    
    // some geometric quantities needed to normalize the detected face.
    
    float dy = pRight.y - pLeft.y;
    float dx = pRight.x - pLeft.x;
    float angle     = atan2(dy,dx);
    float modulus = sqrt(dx*dx+dy*dy);
    
    if (DEBUG) NSLog(@"hand-calculated face angle: %f (%f degrees)",angle,angle*180.0/M_PI);
    
    
    // first step: left eye translate to origin
    CGAffineTransform trx = CGAffineTransformMakeTranslation(-pLeft.x, -pLeft.y);
    if (DEBUG) NSLog(@"trx\n%f %f 0\n%f %f 0\n%f %f 1",trx.a,trx.b,trx.c,trx.d,trx.tx,trx.ty);
    CGPoint tmpLeft = CGPointApplyAffineTransform(pLeft,trx);
    if (DEBUG) NSLog(@"left after trx: %@",NSStringFromCGPoint(tmpLeft));
    
    // second step: rotate right eye to y=0
    trx = CGAffineTransformConcat(trx,CGAffineTransformMakeRotation(-angle));
    if (DEBUG) NSLog(@"trx\n%f %f 0\n%f %f 0\n%f %f 1",trx.a,trx.b,trx.c,trx.d,trx.tx,trx.ty);
    tmpLeft = CGPointApplyAffineTransform(pLeft,trx);
    if (DEBUG) NSLog(@"left after trx+rot: %@",NSStringFromCGPoint(tmpLeft));
    
    // third step: scale x to place eyes at (0,0) and (70,0)
    trx = CGAffineTransformConcat(trx,CGAffineTransformMakeScale(70.0/modulus,70.0/modulus));
    if (DEBUG) NSLog(@"trx\n%f %f 0\n%f %f 0\n%f %f 1",trx.a,trx.b,trx.c,trx.d,trx.tx,trx.ty);
    tmpLeft = CGPointApplyAffineTransform(pLeft,trx);
    if (DEBUG) NSLog(@"left after trx+rot+scale: %@",NSStringFromCGPoint(tmpLeft));
    
    // fourth step: translate by (30,150-45).
    // 150-45 arises from the flipped vertical coordinates for one of the two
    // image coordinate systems.
    trx = CGAffineTransformConcat(trx,CGAffineTransformMakeTranslation(30,150-45));
    if (DEBUG) NSLog(@"trx\n%f %f 0\n%f %f 0\n%f %f 1",trx.a,trx.b,trx.c,trx.d,trx.tx,trx.ty);
    tmpLeft = CGPointApplyAffineTransform(pLeft,trx);
    if (DEBUG) NSLog(@"left after trx+rot+scale+trx: %@",NSStringFromCGPoint(tmpLeft));
    
    CGPoint trxLeft = CGPointApplyAffineTransform(pLeft,trx);
    CGPoint trxRight = CGPointApplyAffineTransform(pRight,trx);
    if (DEBUG) NSLog(@"transformed left: %@  right: %@",NSStringFromCGPoint(trxLeft),NSStringFromCGPoint(trxRight));
    
    // woohoo, make a CIAffineTransform from the CGAffineTransform
    CIFilter *warper = [CIFilter filterWithName:@"CIAffineTransform"];
    if (DEBUG) NSLog(@"warper %@",warper);
    //    CIImage *im = facePicture.CIImage;
    //    NSLog(@"im %@",im);
    //facepicture.C
    [warper setValue:[CIImage imageWithCGImage:facePicture.CGImage] forKey:@"inputImage"];
    [warper setValue:[NSValue valueWithBytes:&trx objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    CIImage *result = [warper valueForKey:@"outputImage"];
    if (DEBUG) NSLog(@"result %@",result);
    
    CGImageRef cgImage = [[CIContext contextWithOptions:nil]
                          createCGImage:result
                          fromRect:CGRectMake(0.0,0.0,130.0,150.0)/*result.extent*/];
    if (DEBUG) NSLog(@"cgImage is %@",cgImage);
    
    UIImage *theImage = [UIImage imageWithCGImage:cgImage];
    
    UIGraphicsBeginImageContext(facePicture.size);
    [facePicture drawAtPoint:CGPointZero];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //left eye is white with red border
    [[UIColor redColor] setStroke];
    [[UIColor whiteColor] setFill];
    CGRect circleRect = CGRectMake(pLeft.x-2,facePicture.size.height-pLeft.y-2,5,5);
    CGContextFillEllipseInRect(ctx,circleRect);
    CGContextStrokeEllipseInRect(ctx,circleRect);
    
    //right eye is green with black border
    [[UIColor blackColor] setStroke];
    [[UIColor greenColor] setFill];
    CGRect circleRectRight = CGRectMake(pRight.x-2,facePicture.size.height-pRight.y-2,5,5);
    CGContextFillEllipseInRect(ctx,circleRectRight);
    CGContextStrokeEllipseInRect(ctx,circleRectRight);
    
    if (faceFeature.hasMouthPosition) {
        // mouth is yellow with blue border
        [[UIColor blueColor] setStroke];
        [[UIColor yellowColor] setFill];
        CGRect circleRectMouth = CGRectMake(pMouth.x-2,facePicture.size.height-pMouth.y-2,5,5);
        CGContextFillEllipseInRect(ctx,circleRectMouth);
        CGContextStrokeEllipseInRect(ctx,circleRectMouth);
    }
    
    UIImage *theImage2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (DEBUG) NSLog(@"markFaces: theImage = %@ size %@",theImage2,NSStringFromCGSize(theImage.size));
    
    //        CGRect newBounds = CGRectMake(faceFeature.bounds.origin.x, ciimage.extent.size.height - faceFeature.bounds.origin.y, faceFeature.bounds.size.width, faceFeature.bounds.size.height);
    //        theImage = [self imageByCropping:facePicture toRect:newBounds];
    UIImageWriteToSavedPhotosAlbum(theImage2, nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum(theImage, nil, nil, nil);
    //    [self sendPic:[self imageByCropping:facePicture toRect:newBounds]];
    if (DEBUG) NSLog(@"out of for loop");
    return theImage;
}



#pragma mark - orientation configuration

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - error handlers

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
