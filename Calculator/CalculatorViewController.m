//
//  CalculatorViewController.m
//  Calculator
//
//  Created by admin on 27/N/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorModel.h"
#import "GraphViewController.h" // Need to communicate to destination controller

@interface CalculatorViewController ()
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (nonatomic) BOOL enteringANumber;
@property (weak, nonatomic) IBOutlet UILabel *programDisplay;
@property (nonatomic, strong) CalculatorModel *calculatorModel;
@end

@implementation CalculatorViewController

- (void)updateDisplay { // Update all aspects of the display on changes
    id result = [CalculatorModel runProgram:self.calculatorModel.program
                        usingVariableValues:nil];
    self.display.text = [NSString stringWithFormat:@"%@", result];
    self.programDisplay.text = [CalculatorModel descriptionOfProgram:
                                self.calculatorModel.program];
}

- (CalculatorModel *)calculatorModel { // overload getter for lazy instantiation
    if (!_calculatorModel) _calculatorModel = [[CalculatorModel alloc] init];
    return _calculatorModel;
}

// Update display features and prevent odd situations
- (IBAction)bufferedItemPressed:(UIButton *)sender {
    NSString *operand = sender.currentTitle;
    
    // FIXME: Pressing . at the beginning displays .x rather than 0.x
    
    if ([self.display.text rangeOfString:@"."].length &&
        [operand isEqualToString:@"."]) { // prevent extra decimals
    } else if (self.enteringANumber && [self.display.text length] == 1 &&
               [self.display.text hasPrefix:@"0"] &&
               [operand isEqualToString:@"0"]) { // do nothing, no leading zeros
    } else if (self.enteringANumber && [self.display.text hasPrefix:@"0"] &&
               ![operand isEqualToString:@"0"]) { // erase leading zero
        self.display.text = operand;
    } else if (self.enteringANumber) { // append anything else
        self.display.text = [self.display.text stringByAppendingString:operand];
    } else { // otherwise, new number
        self.display.text = operand;
        self.enteringANumber = YES;
    }
}

- (IBAction)stackedItemPressed:(UIButton *)sender { // add operation to stack
    NSString *operation = sender.currentTitle;
    if (self.enteringANumber) {
        [self.calculatorModel pushOntoStack:[NSNumber numberWithDouble:
                                             [self.display.text doubleValue]]];
    }
    [self.calculatorModel pushOntoStack:operation];
    [self updateDisplay];
    self.enteringANumber = NO;
}

- (IBAction)enterPressed { // store the digits on the stack
    NSNumber *currentValue = [NSNumber numberWithDouble:
                              [self.display.text doubleValue]];
    [self.calculatorModel pushOntoStack:currentValue];
    [self updateDisplay];
    self.enteringANumber = NO;
}

- (IBAction)undoPressed { // remove digits from the display
    if (self.enteringANumber) {
        NSUInteger stringLength = [self.display.text length];
        if (stringLength > 1) {
            self.display.text = [self.display.text substringToIndex:
                                 (stringLength - 1)];
        } else if (stringLength == 1) {
            [self updateDisplay];
            self.enteringANumber = NO;
        }
    } else { // not entering a number
        [self.calculatorModel removeLastItem];
        [self updateDisplay];
    }
}

- (IBAction)plusMinusPressed { // switch sign of displayed number
    if (self.enteringANumber) {
        double doubleValue = [self.display.text doubleValue] * -1;
        self.display.text = [NSString stringWithFormat:@"%g", doubleValue];
    } else {
        [self.calculatorModel pushOntoStack:@"+/-"];
        [self updateDisplay];
    }
}

- (IBAction)clearPressed { // reset
    [self.calculatorModel clearStack];
    self.enteringANumber = NO;
    [self updateDisplay];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToGraph"]) {
        [segue.destinationViewController
         setProgram:self.calculatorModel.program];
    }
}

@end