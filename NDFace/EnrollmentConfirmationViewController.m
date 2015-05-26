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

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ECVC: viewDidLoad");
 //   [EnrollmentConfirmationLabel setText:@"Something happened."];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) setMessageField:(NSString *) theMessage
{
    [EnrollmentConfirmationLabel setText:theMessage];

}
@end
