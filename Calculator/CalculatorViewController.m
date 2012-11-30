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
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController

// Something here is not right.  Try putting an NSLog(@"here");
// Define the test variable values
- (NSDictionary *)testVariableValues {
    if (!_testVariableValues) _testVariableValues =
                               [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:5], @"x",
                               [NSNumber numberWithDouble:6], @"y",
                               [NSNumber numberWithDouble:7], @"z", nil];
    return _testVariableValues;
}

- (CalculatorBrain *)brain { // overload getter for lazy instantiation
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

// Update display features and prevent odd situations
- (IBAction)operandPressed:(UIButton *)sender {
    NSString *operand = sender.currentTitle;
    if ([operand isEqualToString:@"."]) {
        if (!self.enteredDecimal) { // Prevent multiple decimals
            self.enteredDecimal = YES;
            self.enteringANumber = YES;
            self.display.text =
                [self.display.text stringByAppendingString:operand];
        }
    } else if(self.enteringANumber){ // append to existing number
        self.display.text = [self.display.text
                             stringByAppendingString:operand];
    } else {
        if (![operand isEqualToString:@"0"]) { // Prevent leading zeros
            self.display.text = operand;
            self.enteringANumber = YES;
        }
    }
    if (self.enteringANumber) { // Remove the trailing "= "
        self.queueDisplay.text = [self.queueDisplay.text
            stringByReplacingOccurrencesOfString:@"= " withString:@""];
    }
}

// Store 
- (IBAction)enterPressed {
    id currentValue = self.display.text;
    NSString *testString = [currentValue stringByTrimmingCharactersInSet:
                            [NSCharacterSet decimalDigitCharacterSet]];
    if ([testString isEqualToString:@""]) {
        currentValue = [NSNumber numberWithDouble:
                        [self.display.text doubleValue]];
    }
    [self.brain pushOperand:currentValue];
    // Add the number to the queue display
    self.queueDisplay.text = [[self.queueDisplay.text
                         stringByAppendingString:self.display.text] stringByAppendingString:@" "];
    self.enteringANumber = NO;
    self.display.text = @"0";
    self.enteredDecimal = NO;
}

// Perform operations and update the display
- (IBAction)operationPressed:(UIButton *)sender {
    NSLog(@"test variable values = %@", self.testVariableValues);
    NSString *operation = sender.currentTitle;
    self.queueDisplay.text = [self.queueDisplay.text
                              stringByReplacingOccurrencesOfString:@"= " withString:@""];
    if (self.enteringANumber) [self enterPressed]; // Auto evaluate
    self.queueDisplay.text = [[self.queueDisplay.text
                              stringByAppendingString:operation] stringByAppendingString:@" = "];
    double result = [self.brain performOperation:operation
                                  usingVariables:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

// Remove digits from the display
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

// Alter sign of the displayed number or last stacked number
- (IBAction)plusMinusPressed {
    if (self.enteringANumber) {
        double doubleValue = [self.display.text doubleValue] * -1;
        self.display.text = [NSString stringWithFormat:@"%g", doubleValue];
    } else {
        double result = [self.brain performOperation:@"+/-"
                                      usingVariables:self.testVariableValues];
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
}

// reset
- (IBAction)clearPressed {
    self.display.text = @"0";
    self.queueDisplay.text = @"";
    [self.brain clearStack];
    self.enteredDecimal = NO;
    self.enteringANumber = NO;
}

@end