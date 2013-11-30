//
//  MFRootViewController.h
//  snapradio
//
//  Created by d. nye on 11/21/13.
//  Copyright (c) 2013 Mobile Flow LLC. All rights reserved.
//

#import "MSDynamicsDrawerViewController.h"

@interface MFRootViewControllerSegue : UIStoryboardSegue

@property (strong) void(^performBlock)( MFRootViewControllerSegue* segue, UIViewController* svc, UIViewController* dvc );

@end

@interface MFRootViewController : MSDynamicsDrawerViewController

@end
