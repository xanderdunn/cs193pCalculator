//
//  NonRotatingNavigationViewController.m
//  Calculator
//
//  Created by admin on 18/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "CustomRotatingNavigationViewController.h"

@interface CustomRotatingNavigationViewController ()

@end

@implementation CustomRotatingNavigationViewController

- (BOOL)shouldAutorotate {
    return [[self topViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations { // Support the orientations
    return [[self topViewController] supportedInterfaceOrientations];
}

@end
