//
//  MSExampleControlsViewController.m
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 2/23/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSExampleControlsViewController.h"

@interface MSExampleControlsViewController ()

@property (nonatomic, strong) UILabel *controlDescription;
@property (nonatomic, strong) UISwitch *exampleSwitch;
@property (nonatomic, strong) UISlider *exampleSlider;

@end

@implementation MSExampleControlsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.exampleSwitch = [UISwitch new];
    [self.view addSubview:self.exampleSwitch];
    
    self.exampleSlider = [UISlider new];
    [self.view addSubview:self.exampleSlider];
    
    self.controlDescription = [UILabel new];
    self.controlDescription.numberOfLines = 0;
    self.controlDescription.font = [UIFont systemFontOfSize:15.0];
    self.controlDescription.text = @"Swiping on UISwitch and UISlider will not cause the pane view to slide. This is because their classes have been added to the \"touchForwardingClasses\" set on \"MSNavigationPaneViewController\".";
    [self.view addSubview:self.controlDescription];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat controlDescriptionMargin = 20.0;
    CGSize controlDescriptionSize = [self.controlDescription.text sizeWithFont:self.controlDescription.font constrainedToSize:CGSizeMake(CGRectGetWidth(self.view.frame) - (controlDescriptionMargin * 2.0), CGRectGetHeight(self.view.frame) - (controlDescriptionMargin * 2.0))];
    self.controlDescription.frame = (CGRect){{controlDescriptionMargin, controlDescriptionMargin}, controlDescriptionSize};

    CGFloat controlMargin = 50.0;
    self.exampleSwitch.center = CGPointMake(nearbyintf(self.view.center.x), nearbyintf(self.view.center.y) - (controlMargin / 2.0));
    self.exampleSlider.center = CGPointMake(nearbyintf(self.view.center.x), nearbyintf(self.view.center.y) + (controlMargin / 2.0));
}

@end
