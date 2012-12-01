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
@property (weak, nonatomic) IBOutlet UILabel *programDisplay;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@property (weak, nonatomic) IBOutlet UILabel *variablesDisplay;
@property (nonatomic) int testVariableSetNumber;
@end

@implementation CalculatorViewController

- (void)updateDisplay {
    id result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%@", result];
    self.programDisplay.text = [CalculatorBrain descriptionOfProgram:
                                self.brain.program];
    [self updateVariablesDisplay];
    
}

- (IBAction)testButtonPushed:(UIButton *)sender {
    NSString *testTitle = sender.currentTitle;
    // FIXME: More elegant way of getting the last character in the NSString
    testTitle = [testTitle stringByReplacingOccurrencesOfString:@"Test "
                                                     withString:@""];
    self.testVariableSetNumber = [testTitle intValue];
    [self updateDisplay];
}

- (void) updateVariablesDisplay {
    NSSet *usedVariables = [CalculatorBrain
                            variablesUsedInProgram:self.brain.program];
    
    NSString *displayString = @"";
    
    for (NSString *variable in usedVariables) {
        id value = [self.testVariableValues objectForKey:variable];
        if (value == nil) {
            value = [NSNumber numberWithDouble:NAN];
        }
        displayString = [displayString stringByAppendingFormat:@"%@ = %@   ",
                         variable, value];
    }
    self.variablesDisplay.text = displayString;
}

// Define the test variable values
- (NSDictionary *)testVariableValues {
    if (self.testVariableSetNumber == 1) _testVariableValues =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithDouble:-22.67], @"x",
         [NSNumber numberWithDouble:1000000], @"y",
         [NSNumber numberWithDouble:0], @"z", nil];
    else if (self.testVariableSetNumber == 2) _testVariableValues =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithDouble:5], @"foo",
         [NSNumber numberWithDouble:6], @"bling",
         [NSNumber numberWithDouble:7], @"z", nil];
    else if (self.testVariableSetNumber == 3) _testVariableValues = nil;
    
    return _testVariableValues;
}

- (CalculatorBrain *)brain { // overload getter for lazy instantiation
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

// Update display features and prevent odd situations
- (IBAction)operandPressed:(UIButton *)sender {
    NSString *operand = sender.currentTitle;
    // TODO: Make use of rangeOfString to remove the enteredDecimal property
    if ([operand isEqualToString:@"."]) {
        if (!self.enteredDecimal) { // Prevent multiple decimals
            self.enteredDecimal = YES;
            self.enteringANumber = YES;
            self.display.text =
            [self.display.text stringByAppendingString:operand];
        }
    } else if (self.enteringANumber){ // append to existing number
        self.display.text = [self.display.text
                             stringByAppendingString:operand];
    } else if (![self.display.text hasPrefix:@"0"] &&
               [operand isEqualToString:@"0"]) { // prevent leading zeros
        self.display.text = operand;
    } else if (![operand isEqualToString:@"0"]) {
        self.display.text = operand;
        self.enteringANumber = YES;
    }
    NSString *operandWithoutNumbers = [operand stringByTrimmingCharactersInSet:
                                       [NSCharacterSet
                                        decimalDigitCharacterSet]];
    if (![operandWithoutNumbers isEqualToString:@""] &&
        ![operand isEqualToString:@"."]) { // it is a variable
        [self.brain pushOntoStack:operand];
        [self updateDisplay];
    }
}

// Store the entered digits on the stack
- (IBAction)enterPressed {
    NSNumber *currentValue = [NSNumber numberWithDouble:
                    [self.display.text doubleValue]];
    [self.brain pushOntoStack:currentValue];
    [self updateDisplay];
    self.enteringANumber = NO;
    self.enteredDecimal = NO;
}

// Perform operations and update the display
- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = sender.currentTitle;
    [self.brain pushOntoStack:operation];
    [self updateDisplay];
}

// Remove digits from the display
- (IBAction)undoPressed {
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
        [self.brain removeLastItem];
        [self updateDisplay];
    }
}

// Alter sign of the displayed number or last stacked number
- (IBAction)plusMinusPressed {
    if (self.enteringANumber) {
        double doubleValue = [self.display.text doubleValue] * -1;
        self.display.text = [NSString stringWithFormat:@"%g", doubleValue];
    } else {
        [self.brain pushOntoStack:@"+/-"];
        [self updateDisplay];
    }
}

// reset
- (IBAction)clearPressed {
    [self.brain clearStack];
    self.enteredDecimal = NO;
    self.enteringANumber = NO;
    [self updateDisplay];
}

@end