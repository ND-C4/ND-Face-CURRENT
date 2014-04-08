//
//  ViewController.m
//  NDFace
//
//  Created by Abe on 3/10/14.
//  Copyright (c) 2014 Architecture Information Technology Team. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadEnrollView:(id)sender {
    EnrollViewController *info = [[EnrollViewController alloc] init];
    info.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:info animated:YES completion:Nil];
}
@end
