//
//  MFMenuViewController.m
//  snapradio
//
//  Created by d. nye on 11/21/13.
//  Copyright (c) 2013 Mobile Flow LLC. All rights reserved.
//

#import "MFMenuViewController.h"

@interface MFMenuViewController ()

@end

@implementation MFMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(MFRootViewControllerSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    NSLog(@"PrepareForSegue: %@",identifier);
    if ([identifier isEqualToString:@"pane"]) {
        [_rootVC setPaneViewController:segue.destinationViewController animated:YES completion:nil];
    }
    if ([identifier isEqualToString:@"rear"]) {
        [_rootVC setDrawerViewController:segue.destinationViewController forDirection:MSDynamicsDrawerDirectionLeft];
    }
}

@end
