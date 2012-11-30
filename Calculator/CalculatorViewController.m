//
//  CalculatorViewController.m
//  Calculator
//
//  Created by admin on 27/N/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (nonatomic) BOOL enteringANumber;
@property (nonatomic) BOOL enteredDecimal;
@property (weak, nonatomic) IBOutlet UILabel *queueDisplay;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController
- (CalculatorBrain *)brain { // overload getter for lazy instantiation
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)operandPressed:(UIButton *)sender {
    NSString *digit = sender.currentTitle;
    if ([digit isEqualToString:@"."]) {
        if (!self.enteredDecimal) { // Prevent multiple decimals
            self.enteredDecimal = YES;
            self.enteringANumber = YES;
            self.display.text =
                [self.display.text stringByAppendingString:digit];
        }
    } else if(self.enteringANumber){ // append to existing number
        self.display.text = [self.display.text
                             stringByAppendingString:digit];
    } else {
        if (![digit isEqualToString:@"0"]) { // Prevent leading zeros
            self.display.text = digit;
            self.enteringANumber = YES;
        }
    }
    if (self.enteringANumber) {
        self.queueDisplay.text = [self.queueDisplay.text
            stringByReplacingOccurrencesOfString:@"= " withString:@""];
    }
}

- (IBAction)enterPressed {
    double currentValue = [self.display.text doubleValue];
    [self.brain pushOperand:currentValue];
    // Add the number to the queue display
    self.queueDisplay.text = [[self.queueDisplay.text
                         stringByAppendingString:self.display.text] stringByAppendingString:@" "];
    self.enteringANumber = NO;
    self.display.text = @"0";
    self.enteredDecimal = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = sender.currentTitle;
    self.queueDisplay.text = [self.queueDisplay.text
                              stringByReplacingOccurrencesOfString:@"= " withString:@""];
    if (self.enteringANumber) [self enterPressed]; // Auto evaluate
    self.queueDisplay.text = [[self.queueDisplay.text
                              stringByAppendingString:operation] stringByAppendingString:@" = "];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)backspacePressed {
    NSUInteger stringLength = [self.display.text length];
    if (stringLength > 1) {
        self.display.text = [self.display.text substringToIndex:
                             (stringLength - 1)];
    } else if (stringLength == 1) {
        self.display.text = @"0";
        self.enteringANumber = NO;
    }
}
- (IBAction)plusMinusPressed {
    if (self.enteringANumber) {
        double doubleValue = [self.display.text doubleValue] * -1;
        self.display.text = [NSString stringWithFormat:@"%g", doubleValue];
    } else {
        double result = [self.brain performOperation:@"+/-"];
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
}

- (IBAction)clearPressed {
    self.display.text = @"0";
    self.queueDisplay.text = @"";
    [self.brain clearStack];
    self.enteredDecimal = NO;
    self.enteringANumber = NO;
}

@end