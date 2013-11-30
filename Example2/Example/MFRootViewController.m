//
//  MFRootViewController.m
//  snapradio
//
//  Created by d. nye on 11/21/13.
//  Copyright (c) 2013 Mobile Flow LLC. All rights reserved.
//

#import "MFRootViewController.h"
#import "MFMenuViewController.h"

@implementation MFRootViewControllerSegue

- (void)perform
{
    if ( _performBlock != nil )
    {
        _performBlock( self, self.sourceViewController, self.destinationViewController );
    }
}

@end

@interface MFRootViewController ()

@end

@implementation MFRootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self performSegueWithIdentifier:@"pane" sender:nil];
    [self performSegueWithIdentifier:@"rear" sender:nil];

    self.gravityMagnitude = 1.5;
    self.bounceElasticity = 0.75;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doBouncePaneOpen)
                                                 name:@"MFRootViewBouncePaneOpen"
                                               object: nil];

}

- (void)doBouncePaneOpen
{
    //[self bouncePaneOpenInDirection:MSDynamicsDrawerDirectionLeft];
    [self setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
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
        [self setPaneViewController:segue.destinationViewController];
    }
    if ([identifier isEqualToString:@"rear"]) {
        MFMenuViewController *dvc = (MFMenuViewController *)segue.destinationViewController;
        dvc.rootVC = self;
        [self setDrawerViewController:dvc forDirection:MSDynamicsDrawerDirectionLeft];
        id <MSDynamicsDrawerStyler> scaleStyler = [MSDynamicsDrawerScaleStyler styler];
        [self addStyler:scaleStyler forDirection:MSDynamicsDrawerDirectionLeft];
    }
}

@end
