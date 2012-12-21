//
//  CalculatorProgramsTableViewController.h
//  Calculator
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorProgramsTableViewController;

@protocol CalculatorProgramsTableViewControllerDelegate <NSObject>
@optional
- (void)calculatorProgramsTableViewController:
(CalculatorProgramsTableViewController *)sender choseProgram:(id)program;
@end

@interface CalculatorProgramsTableViewController : UITableViewController
// array of CalculatorBrain programs
@property (nonatomic, strong) NSArray *programs;
// delegate @property for notifying that a program is chosen
@property (nonatomic, weak) id <CalculatorProgramsTableViewControllerDelegate>
delegate;
@end
